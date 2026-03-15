#!/bin/bash

# Nome do Pod (opcional - se vazio, monitora todos)
POD_NAME=$1

# Cores e Ícones
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
ICON_WATCH='👀'
ICON_POD='📦'
ICON_CLOCK='🕒'

clear

while true; do
    # Move o cursor para o topo da tela sem limpar (evita o flicker/piscar)
    tput cup 0 0
    
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${ICON_WATCH}  ${BLUE}K8S MONITOR - Live Status${NC}          ${ICON_CLOCK} $(date +%H:%M:%S)"
    echo -e "${BLUE}============================================================${NC}"
    echo ""

    # Executa o kubectl get pods
    # Se POD_NAME foi passado, filtra por ele, senão mostra todos
    if [ -z "$POD_NAME" ]; then
        kubectl get pods | sed '1d' | while read -r line; do
            STATUS=$(echo $line | awk '{print $3}')
            
            # Aplica ícones baseados no status
            case $STATUS in
                "Running")   COLOR=$GREEN; ICON="✅" ;;
                "Completed") COLOR=$BLUE;  ICON="🏁" ;;
                "Pending")   COLOR=$YELLOW; ICON="⏳" ;;
                "Error"|"CrashLoopBackOff") COLOR=$RED; ICON="❌" ;;
                *)           COLOR=$NC;     ICON="❓" ;;
            esac
            
            echo -e "${ICON} ${COLOR}${line}${NC}"
        done
    else
        kubectl get pods | grep "$POD_NAME" | while read -r line; do
             echo -e "📦 ${GREEN}${line}${NC}"
        done
    fi

    echo ""
    echo -e "${YELLOW}Pressione [CTRL+C] para sair...${NC}"
    
    # Intervalo de 1 segundo
    sleep 1
done