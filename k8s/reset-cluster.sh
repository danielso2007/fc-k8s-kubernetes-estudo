#!/bin/bash

CLUSTER_NAME="lab-cluster"

echo "🧹 Deletando recursos do cluster..."

if kubectl cluster-info > /dev/null 2>&1; then
    kubectl delete all --all --all-namespaces
fi

echo "🧨 Deletando cluster kind..."

if kind get clusters | grep -q $CLUSTER_NAME; then
    kind delete cluster --name $CLUSTER_NAME
    echo "✅ Cluster removido."
else
    echo "⚠️ Cluster não existe."
fi

echo "🧼 Limpando imagens Docker locais (hello-k8s)..."
docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" \
  | grep "^hello-k8s:" \
  | awk '{print $2}' \
  | xargs -r docker rmi -f

echo "🏁 Reset concluído."
