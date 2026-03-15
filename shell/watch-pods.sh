#!/bin/bash

# Nome do Pod (opcional)
POD_NAME=$1

# Cores e Ícones
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
ICON_WATCH='👀'
ICON_CLOCK='🕒'

# Esconde o cursor para uma experiência mais limpa
trap "tput cnorm; exit" INT
tput civis

clear

while true; do
    # Move o cursor para o topo
    tput cup 0 0
    
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${ICON_WATCH}  ${BLUE}K8S MONITOR - Live Status${NC}          ${ICON_CLOCK} $(date +%H:%M:%S)"
    echo -e "${BLUE}============================================================${NC}"
    
    # LIMPA TUDO ABAIXO DO CABEÇALHO (Resolve o problema de "fantasma" de Pods antigos)
    tput ed
    echo ""

    # Captura a saída do kubectl uma única vez para evitar inconsistências
    KUBE_OUTPUT=$(kubectl get pods ${POD_NAME} --no-headers 2>/dev/null)

    if [ -z "$KUBE_OUTPUT" ]; then
        echo -e "${RED}⚠️  Nenhum pod encontrado${NC}"
    else
        while read -r line; do
            # Extrai o status (coluna 3)
            STATUS=$(echo "$line" | awk '{print $3}')
            
            case $STATUS in
                "Running")   COLOR=$GREEN; ICON="✅" ;;
                "Completed") COLOR=$BLUE;  ICON="🏁" ;;
                "Pending")   COLOR=$YELLOW; ICON="⏳" ;;
                "Terminating") COLOR=$YELLOW; ICON="🧹" ;;
                "Error"|"CrashLoopBackOff") COLOR=$RED; ICON="❌" ;;
                *)           COLOR=$NC;     ICON="❓" ;;
            esac
            
            echo -e "${ICON} ${COLOR}${line}${NC}"
        done <<< "$KUBE_OUTPUT"
    fi

    echo ""
    echo -e "${YELLOW}Pressione [CTRL+C] para sair...${NC}"
    
    sleep 1
done