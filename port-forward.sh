#!/bin/bash

# Configurações
APP_LABEL="app=hello-k8s"
LOCAL_PORT=8080
REMOTE_PORT=8080
NAMESPACE="default"

# Cores
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Ícones
ICON_SEARCH='🔍'
ICON_ROCKET='🚀'
ICON_LINK='🔗'
ICON_ERROR='🚨'

echo -e "${BLUE}${ICON_SEARCH} Buscando Pods da aplicação...${NC}"

# Captura a linha completa para mostrar o status no menu
mapfile -t POD_LINES < <(kubectl get pods -n $NAMESPACE -l $APP_LABEL --no-headers)

if [ ${#POD_LINES[@]} -eq 0 ]; then
    echo -e "${RED}${ICON_ERROR} Nenhum pod encontrado com a label: ${YELLOW}$APP_LABEL${NC}"
    exit 1
fi

echo -e "${CYAN}Selecione o Pod para o Port-Forward:${NC}"

# Lista os pods numerados
for i in "${!POD_LINES[@]}"; do
    echo -e "${YELLOW}$((i+1)))${NC} ${POD_LINES[$i]}"
done

echo -ne "\n${GREEN}Digite o número: ${NC}"
read -r CHOICE

INDEX=$((CHOICE-1))

# Valida a escolha e extrai o nome do Pod
if [[ -n "${POD_LINES[$INDEX]}" && "$CHOICE" -gt 0 ]]; then
    SELECTED_POD=$(echo "${POD_LINES[$INDEX]}" | awk '{print $1}')
    
    echo -e "\n${BLUE}${ICON_ROCKET} Iniciando túnel para: ${CYAN}$SELECTED_POD${NC}"
    echo -e "${GREEN}${ICON_LINK} URL: http://localhost:$LOCAL_PORT${NC}"
    echo -e "${YELLOW}Dica: Pressione [CTRL+C] para encerrar o túnel.${NC}\n"
    
    # Executa o port-forward
    kubectl port-forward -n $NAMESPACE pod/$SELECTED_POD $LOCAL_PORT:$REMOTE_PORT
else
    echo -e "${RED}${ICON_ERROR} Opção inválida!${NC}"
    exit 1
fi