#!/bin/bash

# ==============================================================================
# SCRIPT: Monitor de Logs com Stern
# DESCRIÇÃO: Verifica se o Stern está instalado e inicia o streaming de logs
#            multi-pod baseado em labels do Kubernetes.
# ==============================================================================

# --- CONFIGURAÇÕES ---
# A label definida no seu Deployment YAML (ex: app: hello-k8s)
APP_LABEL="app=hello-k8s"

# --- PALETA DE CORES E ÍCONES ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color (Reseta a cor)
ICON_LOGS='📜'
ICON_STERN='⭐'
ICON_DOWNLOAD='📥'
ICON_CHECK='✅'
ICON_INFO='ℹ️'

echo -e "${CYAN}--------------------------------------------------------${NC}"
echo -e "${ICON_LOGS}  Buscando logs para pods com a label: ${YELLOW}$APP_LABEL${NC}"
echo -e "${ICON_INFO}  Dica: O Stern diferencia cada réplica por cor.${NC}"
echo -e "${CYAN}--------------------------------------------------------${NC}"

# --- VERIFICAÇÃO DE PRÉ-REQUISITOS ---
# Checa se o kubectl (necessário para o Stern funcionar) está no PATH
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Erro: kubectl não encontrado. O Stern precisa dele para acessar o cluster.${NC}"
    exit 1
fi

# --- LÓGICA DE INSTALAÇÃO DO STERN ---
# O comando 'command -v' retorna 0 se o binário existir no sistema
if ! command -v stern &> /dev/null; then
    echo -e "${YELLOW}${ICON_DOWNLOAD} Stern não encontrado. Iniciando instalação automatizada...${NC}"
    
    # Cria um diretório temporário para não sujar sua pasta atual
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || exit
    
    # Baixa o binário oficial do GitHub (Versão estável para Linux AMD64)
    curl -L -o stern.tar.gz https://github.com/stern/stern/releases/download/v1.31.0/stern_1.31.0_linux_amd64.tar.gz
    
    # Extrai o conteúdo do arquivo comprimido
    tar -xf stern.tar.gz
    
    # Move o binário para uma pasta do sistema que está no seu PATH
    # O 'sudo' é necessário para escrever em /usr/local/bin
    echo -e "${CYAN}${ICON_STERN} Movendo stern para /usr/local/bin (solicitando permissão)...${NC}"
    sudo mv stern /usr/local/bin/
    
    # Garante que o arquivo seja um executável
    sudo chmod +x /usr/local/bin/stern
    
    # Volta para o diretório anterior e remove os arquivos temporários de instalação
    cd - > /dev/null || exit
    rm -rf "$TEMP_DIR"
    
    echo -e "${GREEN}${ICON_CHECK} Stern instalado com sucesso!${NC}"
else
    echo -e "${GREEN}${ICON_CHECK} Stern detectado no sistema. Preparando stream...${NC}"
fi

# --- EXECUÇÃO DO MONITORAMENTO ---
# EXPLICAÇÃO DAS FLAGS:
# --selector: Filtra os pods pela label informada no topo do script.
# --tail 20:   Recupera as últimas 40 linhas de log de cada pod assim que inicia.
# (Opcional) --color always: Força a saída colorida mesmo através de pipes.
# Nota: O Stern monitora automaticamente novos pods que surgirem com essa label.

stern --selector "$APP_LABEL" --tail 40