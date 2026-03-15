#!/bin/bash

# Cores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Ícones
ICON_API='⚙️'
ICON_CHECK='✅'
ICON_ERROR='🚨'
ICON_INFO='ℹ️'

echo -e "${PURPLE}${ICON_API} Listando API Services do Cluster (Corrigido)...${NC}"
echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"

# Captura os dados
mapfile -t API_LINES < <(kubectl get apiservices --no-headers)

for line in "${API_LINES[@]}"; do
    NAME=$(echo "$line" | awk '{print $1}')
    
    # Lógica corrigida: Procuramos a palavra 'True' na linha inteira
    if echo "$line" | grep -q "True"; then
        STATUS_COLOR=$GREEN
        STATUS_ICON=$ICON_CHECK
        AVAILABLE="True"
    else
        STATUS_COLOR=$RED
        STATUS_ICON=$ICON_ERROR
        AVAILABLE="False"
    fi

    # Extrai o SERVICE (segunda coluna) e a AGE (última coluna)
    SERVICE=$(echo "$line" | awk '{print $2}')
    AGE=$(echo "$line" | awk '{print $NF}') # $NF pega sempre a última coluna (idade)

    printf "${STATUS_ICON} ${STATUS_COLOR}%-45s${NC} | Service: %-20s | Age: %s\n" "$NAME" "$SERVICE" "$AGE"
done

echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
echo -e "${YELLOW}${ICON_INFO} Total de API Services: ${#API_LINES[@]}${NC}"