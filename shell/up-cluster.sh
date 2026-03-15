#!/bin/bash
set -e

CLUSTER_NAME="lab-cluster"
KIND_CONFIG="k8s/cluster/kind.yml"
IMAGE_NAME="hello-k8s:latest"
ICON_ROCKET='🚀'; ICON_BUILD='📦'; ICON_LOAD='📤'; ICON_YAML='📄'; ICON_WAIT='⏳'; ICON_CHECK='✅'

echo "🚀 Criando cluster kind..."

if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
kind create cluster --config $KIND_CONFIG --name $CLUSTER_NAME
else
echo "⚠️ Cluster já existe."
fi

echo "📦 Buildando imagem..."

pushd api-java-exemplo/hello-k8s > /dev/null
docker build -t $IMAGE_NAME .
popd > /dev/null

echo "📤 Carregando imagem no kind..."
kind load docker-image $IMAGE_NAME --name $CLUSTER_NAME

echo -e "${YELLOW}🧹 Limpando recursos antigos para evitar conflitos...${NC}"
# Deleta o deployment mas mantém o resto (ou use delete -f ./k8s se quiser limpar tudo)
kubectl delete deployment hello-k8s --ignore-not-found=true

# Aguarda um pouco para o K8s processar a limpeza
sleep 5

echo "📄 Aplicando manifestos Kubernetes..."
kubectl apply -f ./k8s

echo -e "${BLUE}${ICON_WAIT} Aguardando estabilização do Deployment...${NC}"
sleep 2

echo -e "${BLUE}${ICON_WAIT} Aguardando rollout...${NC}"
# O rollout status já garante que o novo ReplicaSet esteja pronto e os pods antigos removidos
if ! kubectl rollout status deployment hello-k8s --timeout=60s; then
    echo -e "${RED}❌ Erro: O Rollout falhou ou expirou tempo limite.${NC}"
    kubectl describe deployment hello-k8s
    exit 1
fi

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
echo -e "${GREEN}${ICON_CHECK} Ambiente pronto.${NC}"
