#!/bin/bash

# Configurações
HPA_NAME="hello-k8s-hpa"
CPU_THRESHOLD=80
MEM_THRESHOLD=90

# Cores
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Ícones
ICON_CPU='⚡'
ICON_MEM='🧠'
ICON_ALERT='🚨'

echo -e "${CYAN}🚀 Iniciando monitoramento em tempo real...${NC}"
sleep 1

while true; do
    clear
    echo -e "${CYAN}============================================================${NC}"
    echo -e "📅 $(date '+%Y-%m-%d %H:%M:%S') | Cluster: lab-cluster"
    echo -e "${CYAN}============================================================${NC}"

    # Seção HPA
    echo -e "\n${GREEN}⚖️  STATUS DO HPA:${NC}"
    kubectl get hpa $HPA_NAME || echo "HPA não encontrado."
    
    echo -e "${CYAN}------------------------------------------------------------${NC}"

    # Seção de Consumo Real
    echo -e "${GREEN}📊 CONSUMO REAL (TOP PODS):${NC}"
    kubectl top pod | grep "hello-k8s" || echo "Nenhum pod encontrado."

    echo -e "${CYAN}============================================================${NC}"
    
    # Captura métricas do HPA (JSONPath pode variar dependendo da ordem no YAML)
    # CPU geralmente é o índice 0, Memória índice 1
    CPU_USAGE=$(kubectl get hpa $HPA_NAME -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' 2>/dev/null)
    MEM_USAGE=$(kubectl get hpa $HPA_NAME -o jsonpath='{.status.currentMetrics[1].resource.current.averageUtilization}' 2>/dev/null)
    
    # Alerta de CPU
    if [ ! -z "$CPU_USAGE" ] && [ "$CPU_USAGE" -gt $CPU_THRESHOLD ]; then
        echo -e "${RED}${ICON_ALERT} ALERTA CPU: ${ICON_CPU} ${CPU_USAGE}% (Limite: ${CPU_THRESHOLD}%)${NC}"
    fi

    # Alerta de Memória
    if [ ! -z "$MEM_USAGE" ] && [ "$MEM_USAGE" -gt $MEM_THRESHOLD ]; then
        echo -e "${RED}${ICON_ALERT} ALERTA MEMÓRIA: ${ICON_MEM} ${MEM_USAGE}% (Limite: ${MEM_THRESHOLD}%)${NC}"
    fi

    echo -e "\n${YELLOW}Pressione CTRL+C para sair.${NC}"
    sleep 2
done