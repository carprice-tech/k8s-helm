#!/bin/bash

echo $1
echo $2

NS=$1
SERVICES="rabbitmq"
SERVICES=$2
USER=$3
TASK=$4

if [ "$NS" != "default" ]
  then
    echo "NO! Only default namespace can be used"
    exit 1
fi

[ -z "$NS" ] && echo "missing namespace" && exit 3

if [ "$SERVICES" == "all" ]
  then
    SERVICES="init-dev rabbitmq"
fi

echo "" > .k8s.yaml

if [ "$USER" == "prod" ] || [ "$USER" == "stage" ]; then
  if [ "$USER" == "stage" ]; then
 #   kubectl config use-context default/stage
    if [ $? -ne 0 ]; then echo "switch context failed. exit.."; exit 1; fi
 #   consul-template -vault-retry-attempts=10 -config vault-config.hcl -template "./stage/stage.ctmpl.yaml:./devserver/tasks/stage.yaml" -once
    if [ $? -ne 0 ]; then echo "consul-template error. exit.."; exit 1; fi
  fi
  if [ "$USER" == "prod" ]; then
    kubectl config use-context default/prod
    if [ $? -ne 0 ]; then echo "switch context failed. exit.."; exit 1; fi
    consul-template -vault-retry-attempts=10 -config vault-config.hcl -template "./prod/prod.ctmpl.yaml:./devserver/tasks/prod.yaml" -once
    if [ $? -ne 0 ]; then echo "consul-template error. exit.."; exit 1; fi
  fi
  if [ "$SERVICES" == "grafana-mcs" ]; then
    helm template -f ./dev/main.yaml -f ./dev/grafana-mcs.yaml -f devserver/tasks/${TASK}.yaml ./Charts/grafana-mcs >> .k8s.yaml
    if [ $? -ne 0 ]; then echo "helm template error. exit.."; exit 1; fi
    GRAFANA_PATCH=$(cat <<EOF
spec:
  template:
    spec:
      containers:
      - env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: admin
        - name: GF_DASHBOARDS_JSON_ENABLED
          value: "true"
        - name: GF_DASHBOARDS_JSON_PATH
          value: "/var/lib/grafana/dashboards"
        - name: GF_SERVER_ROOT_URL
          value:
        name: grafana
EOF
)
    kubectl -n prometheus-monitoring patch deployment grafana --patch "$GRAFANA_PATCH"
    kubectl -n prometheus-monitoring apply -f .k8s.yaml
    rm .k8s.yaml
    exit 0
  fi
  if [ "$SERVICES" == "logs" ]; then
    kubectl create namespace logging
    helm template -f ./dev/main.yaml -f ./dev/logs.yaml -f devserver/tasks/${TASK}.yaml ./Charts/logs >> .k8s.yaml
    if [ $? -ne 0 ]; then echo "helm template error. exit.."; exit 1; fi
    kubectl -n logging      apply -f .k8s.yaml
    INGRESS_PATCH=$(cat <<EOF
spec:
  template:
    metadata:
      annotations:
        fluentbit.io/parser: nginx
EOF
)
    kubectl -n ingress-nginx patch deployment nginx-ingress-controller --patch "$INGRESS_PATCH"
    rm .k8s.yaml
    exit 0
  fi
fi

for svc in $SERVICES; do
    helm template -f ./dev/main.yaml -f ./dev/$svc.yaml $(for x in devserver/users/${USER}_*.yaml; do echo -n " -f $x"; done;) -f devserver/tasks/${TASK}.yaml ./Charts/$svc >> .k8s.yaml
    if [ $? -ne 0 ]; then echo "helm template error. exit.."; exit 1; fi
done;

if [ "$5" == "run" ]
  then
    echo "run deploy"
    if [ -z `kubectl get namespace $NS --no-headers --output=go-template={{.metadata.name}} 2>/dev/null` ]; then
      kubectl create ns $NS
    fi
    if [ -z `kubectl -n default get secret regcred --no-headers --output=go-template={{.metadata.name}} 2>/dev/null` ]; then 
      kubectl create secret docker-registry regcred --docker-server=registry.gitlab.com --docker-username=$CI_REGISTRY_USER --docker-password=$CI_REGISTRY_PASSWORD --docker-email=admin@example.com -n $NS
    fi
    kubectl -n $NS -f .k8s.yaml apply
    rm .k8s.yaml
  else
    echo "dry run, check .k8s.yaml file"
fi
