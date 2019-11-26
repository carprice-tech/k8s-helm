FROM alpine:3.10.1

ARG CONSUL_TEMPLATE_VERSION="0.20.0"
ARG CONSUL_TEMPLATE_SHA256="500fe023c89517f959175eb79e21c33df0acf7733d3f3681ec8c5238863caf86"

ARG KUBE_VERSION="v1.15.1"
ARG KUBE_SHA256="f4f4b855ab16ef295bc74f07edc77482d43e8fe81abc7cf92c476c4344788aa6"

ARG HELM_VERSION="v2.14.2"
ARG HELM_SHA256="9f50e69cf5cfa7268b28686728ad0227507a169e52bf59c99ada872ddd9679f0"

RUN apk --no-cache upgrade && \
  apk --no-cache add bash curl ca-certificates && \
  curl -o /tmp/consul-template.zip -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
  echo "${CONSUL_TEMPLATE_SHA256}  /tmp/consul-template.zip" | sha256sum -c - && \
  unzip /tmp/consul-template.zip -d /usr/bin/ && \
  rm -f /tmp/consul-template.zip && \
  curl -o /tmp/helm.tar.gz -L https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
  echo "${HELM_SHA256}  /tmp/helm.tar.gz" | sha256sum -c - && \
  tar xfz /tmp/helm.tar.gz && mv linux-amd64/helm /bin/helm && \
  rm -rf linux-amd64 && \
  curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
  echo "${KUBE_SHA256}  /usr/local/bin/kubectl" | sha256sum -c - && \
  chmod +x /usr/local/bin/kubectl

RUN mkdir /root/.kube

ADD Charts/ /root/k8s-helm/Charts/
ADD prod/ /root/k8s-helm/prod/
ADD stage/ /root/k8s-helm/stage/
ADD dev/ /root/k8s-helm/dev/
ADD devserver/ /root/k8s-helm/devserver/

WORKDIR /root/k8s-helm
