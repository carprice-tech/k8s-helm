#!/bin/bash
namespaces="kube-system default"
for ns in $namespaces; do
    kubectl --namespace=$ns get pods | grep Evicted | awk '{print $1}' | xargs kubectl --namespace=$ns delete pod
done;
