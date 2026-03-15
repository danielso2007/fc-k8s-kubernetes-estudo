#!/bin/bash
set -e

CLUSTER_NAME="lab-cluster"
KIND_CONFIG="./cluster/kind.yml"
IMAGE_NAME="hello-k8s:latest"

echo "🚀 Criando cluster kind..."

if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
kind create cluster --config $KIND_CONFIG --name $CLUSTER_NAME
else
echo "⚠️ Cluster já existe."
fi

echo "📦 Buildando imagem..."

pushd ../api-java-exemplo/hello-k8s > /dev/null
docker build -t $IMAGE_NAME .
popd > /dev/null

echo "📤 Carregando imagem no kind..."
kind load docker-image $IMAGE_NAME --name $CLUSTER_NAME

echo "📄 Aplicando manifestos Kubernetes..."
kubectl apply -f .

echo "⏳ Aguardando rollout..."
kubectl rollout status deployment hello-k8s --timeout=120s

echo "⏳ Aguardando pods ficarem Ready..."
kubectl wait --for=condition=Ready pod -l app=hello-k8s --timeout=120s

echo ""
echo "==================== 📊 ESTADO DO CLUSTER ===================="
echo ""

echo "🔹 Nodes:"
kubectl get nodes -o wide
echo ""

echo "🔹 Namespaces:"
kubectl get ns
echo ""

echo "🔹 Deployments:"
kubectl get deployments -o wide
echo ""

echo "🔹 ReplicaSets:"
kubectl get rs -o wide
echo ""

echo "🔹 Pods:"
kubectl get pods -o wide
echo ""

echo "🔹 Services:"
kubectl get svc -o wide
echo ""

echo "🔹 EndpointSlices:"
kubectl get endpointslices
echo ""

echo "==============================================================="
echo ""
echo "✅ Ambiente pronto."
