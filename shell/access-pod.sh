#!/bin/bash

# --- CONFIGURAÇÕES ---
APP_LABEL="app=hello-k8s"

# --- CORES E ÍCONES ---
CYAN='\033[0;36m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
ICON_SEARCH='🔍'; ICON_POD='📦'; ICON_ENTER='🚪'; ICON_ERROR='🚨'

echo -e "${CYAN}${ICON_SEARCH} Procurando pods disponíveis...${NC}"

# Obtém a lista de nomes dos pods
MAPFILE=($(kubectl get pods -l $APP_LABEL -o jsonpath="{.items[*].metadata.name}"))

# Verifica se a lista está vazia
if [ ${#MAPFILE[@]} -eq 0 ]; then
    echo -e "${RED}${ICON_ERROR} Nenhum pod encontrado com a label $APP_LABEL.${NC}"
    exit 1
fi

# Se houver apenas um pod, entra direto. Se houver mais, oferece escolha.
if [ ${#MAPFILE[@]} -eq 1 ]; then
    SELECTED_POD=${MAPFILE[0]}
    echo -e "${GREEN}${ICON_POD} Apenas um pod encontrado: $SELECTED_POD${NC}"
else
    echo -e "${YELLOW}Vários pods detectados. Escolha qual deseja acessar:${NC}"
    # Itera sobre o array para criar o menu de seleção
    for i in "${!MAPFILE[@]}"; do
        echo -e "$((i+1))) ${MAPFILE[$i]}"
    done

    echo -ne "${CYAN}Digite o número: ${NC}"
    read -r CHOICE
    
    # Valida a escolha do usuário
    INDEX=$((CHOICE-1))
    if [[ $INDEX -lt 0 || $INDEX -ge ${#MAPFILE[@]} ]]; then
        echo -e "${RED}${ICON_ERROR} Opção inválida.${NC}"
        exit 1
    fi
    SELECTED_POD=${MAPFILE[$INDEX]}
fi

# --- EXECUÇÃO ---
echo -e "${CYAN}${ICON_ENTER} Verificando status do pod: $SELECTED_POD...${NC}"

# Aguarda ficar pronto para evitar erro de conexão
kubectl wait --for=condition=Ready pod/$SELECTED_POD --timeout=30s

echo -e "${GREEN}Entrando no terminal do pod: ${YELLOW}$SELECTED_POD${NC}"
echo -e "${CYAN}Dica: Digite 'exit' para sair do container.${NC}\n"

# Executa o terminal interativo
# Nota: Usamos 'sh' como fallback, mas se sua imagem tiver 'bash', pode trocar.
kubectl exec -it "$SELECTED_POD" -- sh