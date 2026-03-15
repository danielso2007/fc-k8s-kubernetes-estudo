#!/bin/bash

# Configurações
IMAGE_NAME="hello-k8s"
VERSION="0.2.0"
CLUSTER_NAME="lab-cluster"
DEPLOYMENT="hello-k8s"

# Cores
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

# Ícones
ICON_BUILD='🔨'
ICON_TAG='🏷️'
ICON_KIND='📦'
ICON_RESTART='🔄'
ICON_IMAGE='🖼️'
ICON_SUCCESS='✅'
ICON_ERROR='🚨'

# 1. Build da Imagem
echo -e "${BLUE}${ICON_BUILD} Buildando imagem: ${CYAN}${IMAGE_NAME}:${VERSION}${NC}"
if ! docker build -t ${IMAGE_NAME}:${VERSION} .; then
    echo -e "${RED}${ICON_ERROR} Falha no Docker Build. Abortando...${NC}"
    exit 1
fi

# 2. Tagging
echo -e "${PURPLE}${ICON_TAG} Aplicando tag latest...${NC}"
docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest

# 3. Load no Kind (Passo crucial para o laboratório)
echo -e "${YELLOW}${ICON_KIND} Carregando imagem no cluster Kind: ${CLUSTER_NAME}...${NC}"
if ! kind load docker-image ${IMAGE_NAME}:${VERSION} --name $CLUSTER_NAME; then
    echo -e "${RED}${ICON_ERROR} Falha ao carregar imagem no Kind. O cluster está rodando?${NC}"
    exit 1
fi

# 4. Restart do Deployment
echo -e "${CYAN}${ICON_RESTART} Forçando reinício do deployment: ${DEPLOYMENT}${NC}"
kubectl rollout restart deployment $DEPLOYMENT

# 5. Verificação Final
echo -e "\n${BLUE}${ICON_IMAGE} Resumo das imagens locais:${NC}"
docker images | grep ${IMAGE_NAME}

echo -e "\n${GREEN}${ICON_SUCCESS} Processo finalizado com sucesso no cluster ${CLUSTER_NAME}!${NC}"