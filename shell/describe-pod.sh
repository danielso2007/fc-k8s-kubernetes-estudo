#!/bin/bash

# Cores
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Ícones
ICON_LIST='📋'
ICON_POD='📦'
ICON_DESC='🔍'
ICON_ERROR='🚨'

echo -e "${BLUE}${ICON_LIST} Listando Pods e Status...${NC}"

# Captura a linha completa do 'kubectl get pods' em um array (pulando o cabeçalho)
mapfile -t POD_LINES < <(kubectl get pods --no-headers)

# Verifica se existem pods
if [ ${#POD_LINES[@]} -eq 0 ]; then
    echo -e "${RED}${ICON_ERROR} Nenhum Pod encontrado no namespace atual.${NC}"
    exit 1
fi

echo -e "${CYAN}Escolha o Pod para detalhar (Describe):${NC}"
echo -e "${BLUE}--------------------------------------------------------------------------------${NC}"

# Exibe as linhas numeradas
for i in "${!POD_LINES[@]}"; do
    # Extrai o status para colorir a linha (coluna 3)
    STATUS=$(echo "${POD_LINES[$i]}" | awk '{print $3}')
    
    case $STATUS in
        "Running")   COLOR=$GREEN ;;
        "Pending")   COLOR=$YELLOW ;;
        *)           COLOR=$RED ;;
    esac

    echo -e "${YELLOW}$((i+1)))${NC} ${ICON_POD} ${COLOR}${POD_LINES[$i]}${NC}"
done

echo -e "${BLUE}--------------------------------------------------------------------------------${NC}"

# Lê a opção do usuário
echo -ne "${GREEN}Digite o número do Pod: ${NC}"
read -r CHOICE

# Ajusta o índice
INDEX=$((CHOICE-1))

# Valida a escolha e extrai apenas o NOME do pod (primeira coluna)
if [[ -n "${POD_LINES[$INDEX]}" && "$CHOICE" -gt 0 ]]; then
    SELECTED_POD=$(echo "${POD_LINES[$INDEX]}" | awk '{print $1}')
    
    echo -e "\n${BLUE}${ICON_DESC} Abrindo describe do: ${CYAN}$SELECTED_POD${NC}\n"
    
    # Executa o describe
    kubectl describe pod "$SELECTED_POD"
else
    echo -e "${RED}${ICON_ERROR} Opção inválida! Operação cancelada.${NC}"
    exit 1
fi