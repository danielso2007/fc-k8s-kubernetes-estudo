#!/bin/bash

# Configurações
IMAGE_NAME="hello-k8s"
CLUSTER_NAME="lab-cluster"
DEPLOYMENT="hello-k8s"
POM_FILE="pom.xml"

# Cores e Ícones
BLUE='\033[0;34m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
PURPLE='\033[0;35m'; RED='\033[0;31m'; NC='\033[0m'
ICON_BUILD='🔨'; ICON_TAG='🏷️'; ICON_KIND='📦'; ICON_RESTART='🔄'; ICON_SUCCESS='✅'; ICON_ERROR='🚨'; ICON_VERSION='📦'

# 1. Extrair versão do pom.xml (Lógica de precisão)
if [ ! -f "$POM_FILE" ]; then
    echo -e "${RED}${ICON_ERROR} Arquivo pom.xml não encontrado!${NC}"
    exit 1
fi

# Pega a versão que está LOGO APÓS o artifactId do projeto para não confundir com o parent (Spring)
CURRENT_VERSION=$(sed -n '/<artifactId>'"$IMAGE_NAME"'<\/artifactId>/ {n;p}' "$POM_FILE" | sed -E 's/.*<version>(.*)<\/version>.*/\1/')

# Fallback caso a estrutura do POM varie (se o artifactId e version não estiverem em linhas seguidas)
if [[ -z "$CURRENT_VERSION" ]]; then
    CURRENT_VERSION=$(grep -m 1 "<version>" "$POM_FILE" | sed 's/[^0-9.]*//g')
fi

echo -e "${BLUE}${ICON_VERSION} Maven Version Manager (Project Only)${NC}"
echo -e "Versão do Projeto: ${YELLOW}$CURRENT_VERSION${NC}"
echo -e "1) Incrementar Patch (ex: 0.0.x)"
echo -e "2) Incrementar Minor (ex: 0.x.0)"
echo -e "3) Apenas Buildar (Manter atual)"
echo -e "4) Digitar manualmente"
echo -ne "${CYAN}Escolha uma opção: ${NC}"
read -r OPT

# Decomposição
MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
PATCH=$(echo "$CURRENT_VERSION" | cut -d. -f3)

case $OPT in
    1) VERSION="$MAJOR.$MINOR.$((PATCH + 1))" ;;
    2) VERSION="$MAJOR.$((MINOR + 1)).0" ;;
    4) echo -ne "${YELLOW}Digite a nova versão: ${NC}"; read -r VERSION ;;
    *) VERSION=$CURRENT_VERSION ;;
esac

# Atualiza o pom.xml com precisão cirúrgica
if [ "$VERSION" != "$CURRENT_VERSION" ]; then
    # Substitui a versão apenas no bloco que contém o artifactId do projeto
    sed -i "/<artifactId>$IMAGE_NAME<\/artifactId>/!b;n;c\    <version>$VERSION</version>" "$POM_FILE"
    echo -e "${GREEN}${ICON_SUCCESS} pom.xml atualizado para ${YELLOW}$VERSION${NC}"
fi

# 2. Build da Imagem
echo -e "\n${BLUE}${ICON_BUILD} Buildando imagem: ${CYAN}${IMAGE_NAME}:${VERSION}${NC}"
if ! docker build -t ${IMAGE_NAME}:${VERSION} .; then
    echo -e "${RED}${ICON_ERROR} Falha no Docker Build.${NC}"
    exit 1
fi

# 3. Tagging
docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest

# 4. Load no Kind
echo -e "${YELLOW}${ICON_KIND} Carregando no Kind: ${CLUSTER_NAME}...${NC}"
kind load docker-image ${IMAGE_NAME}:${VERSION} --name "$CLUSTER_NAME"

# 5. Restart do Deployment
echo -e "${CYAN}${ICON_RESTART} Reiniciando Deployment: ${DEPLOYMENT}${NC}"
kubectl rollout restart deployment "$DEPLOYMENT"

echo -e "\n${GREEN}${ICON_SUCCESS} Pipeline Finalizado!${NC}"
echo -e "Versão final: ${YELLOW}$VERSION${NC}"