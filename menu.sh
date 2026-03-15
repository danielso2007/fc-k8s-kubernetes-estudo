a#!/bin/bash

# --- CONFIGURAÇÃO DE CAMINHO ---
# Pasta onde residem os seus scripts .sh
SHELL_DIR="./shell"

# --- CORES E ÍCONES ---
BLUE='\033[0;34m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
PURPLE='\033[0;35m'; RED='\033[0;31m'; NC='\033[0m'
ICON_MENU='🎮'; ICON_EXEC='🚀'; ICON_EXIT='👋'; ICON_FOLDER='📂'

# --- FUNÇÃO PARA EXECUTAR SCRIPT ---
run_script() {
    # Monta o caminho completo: ./shell/nome-do-script.sh
    SCRIPT_PATH="$SHELL_DIR/$1"
    
    if [ -f "$SCRIPT_PATH" ]; then
        echo -e "\n${BLUE}${ICON_EXEC} Executando: ${YELLOW}$SCRIPT_PATH${NC}\n"
        # Executa o script passando o caminho correto
        bash "$SCRIPT_PATH"
    else
        echo -e "\n${RED}🚨 Erro: Arquivo $1 não encontrado em $SHELL_DIR!${NC}"
    fi
    echo -e "\n${CYAN}Pressione [Enter] para voltar ao menu...${NC}"
    read
}

while true; do
    clear
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${ICON_MENU}  ${BLUE}K8S LAB MANAGER - Painel de Controle${NC}"
    echo -e "${ICON_FOLDER}  Caminho atual: ${PURPLE}$SHELL_DIR/${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}Escolha uma operação:${NC}\n"

    echo -e "${YELLOW}--- CLUSTER & DEPLOY ---${NC}"
    echo -e "1)  up-cluster.sh"
    echo -e "2)  reset-cluster.sh"
    echo -e "3)  build-api-java-exemplo.sh"
    echo -e "4)  redeploy.sh"

    echo -e "\n${YELLOW}--- MONITORAMENTO ---${NC}"
    echo -e "5)  watch-pods.sh"
    echo -e "6)  logs-pods.sh"
    echo -e "7)  monitor-hpa.sh"
    echo -e "8)  apiservices-list-chech.sh"

    echo -e "\n${YELLOW}--- ACESSO & DEBUG ---${NC}"
    echo -e "9)  port-forward-pod.sh"
    echo -e "10) access-pod.sh"
    echo -e "11) describe-pod.sh"

    echo -e "\n${RED}0)  Sair${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -ne "${CYAN}Opção: ${NC}"
    read -r OPT

    case $OPT in
        1)  run_script "up-cluster.sh" ;;
        2)  run_script "reset-cluster.sh" ;;
        3)  run_script "build-api-java-exemplo.sh" ;;
        4)  run_script "redeploy.sh" ;;
        5)  run_script "watch-pods.sh" ;;
        6)  run_script "logs-pods.sh" ;;
        7)  run_script "monitor-hpa.sh" ;;
        8)  run_script "apiservices-list-chech.sh" ;;
        9)  run_script "port-forward-pod.sh" ;;
        10) run_script "access-pod.sh" ;;
        11) run_script "describe-pod.sh" ;;
        0)  echo -e "\n${PURPLE}${ICON_EXIT} Saindo...${NC}\n"; exit 0 ;;
        *)  echo -e "\n${RED}Opção inválida!${NC}"; sleep 1 ;;
    esac
done