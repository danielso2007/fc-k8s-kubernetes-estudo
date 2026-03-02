#!/bin/bash

# Define a label que usamos no seu YAML
APP_LABEL="app=hello-k8s"

echo "--------------------------------------------------------"
echo "Buscando logs para pods com a label: $APP_LABEL"
echo "Dica: Pressione CTRL+C para parar."
echo "--------------------------------------------------------"

# Verifica se o kubectl está instalado
# if ! command -v kubectl &> /dev/null; then
#     echo "Erro: kubectl não encontrado. Instale-o para continuar."
#     exit 1
# fi

# Comando principal: 
# -l: filtra pela label
# --all-containers: caso você adicione sidecars no futuro
# -f: (follow) acompanha os logs em tempo real
# --prefix: mostra o nome do pod antes de cada linha de log (muito útil para 3 réplicas)
# kubectl logs -l $APP_LABEL -f --all-containers --prefix --tail=20



# Baixa a versão mais recente (substitua 'linux_amd64' se estiver em ARM)
curl -L -o stern.tar.gz https://github.com/stern/stern/releases/download/v1.31.0/stern_1.31.0_linux_amd64.tar.gz
tar -xvf stern.tar.gz
sudo mv stern /usr/local/bin/
sudo chmod +x /usr/local/bin/stern
rm stern.tar.gz LICENSE README.md

stern hello-k8s $APP_LABEL
