#!/bin/bash

# Configurações
DEPLOYMENT="hello-k8s"

# Cores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sem cor

# Ícones
ICON_RESTART='🔄'
ICON_CHECK='✅'
ICON_WAIT='⏳'
ICON_ERROR='🚨'

echo -e "${CYAN}${ICON_RESTART} Iniciando reinício forçado do deployment: ${YELLOW}$DEPLOYMENT${NC}"

# 1. Verifica se o deployment existe antes de tentar o restart
if ! kubectl get deployment "$DEPLOYMENT" > /dev/null 2>&1; then
    echo -e "${RED}${ICON_ERROR} Erro: Deployment '$DEPLOYMENT' não encontrado no namespace atual.${NC}"
    exit 1
fi

# 2. Executa o restart (gera uma nova revisão no ReplicaSet)
kubectl rollout restart deployment "$DEPLOYMENT"

echo -e "${YELLOW}${ICON_WAIT} Aguardando rollout finalizar...${NC}"

# 3. Monitora o status do rollout em tempo real
if kubectl rollout status deployment "$DEPLOYMENT"; then
    echo ""
    echo -e "${GREEN}${ICON_CHECK} Sucesso! O deployment ${YELLOW}$DEPLOYMENT${GREEN} foi reiniciado e está online.${NC}"
else
    echo ""
    echo -e "${RED}${ICON_ERROR} Falha no rollout do deployment: $DEPLOYMENT${NC}"
    exit 1
fi
