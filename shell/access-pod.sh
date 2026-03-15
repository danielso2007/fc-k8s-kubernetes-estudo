#!/bin/bash

APP_LABEL="app=hello-k8s"

echo "Procurando pod..."

POD=$(kubectl get pods -l $APP_LABEL -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD" ]; then
echo "Nenhum pod encontrado."
exit 1
fi

echo "Aguardando pod ficar Ready..."

kubectl wait --for=condition=Ready pod/$POD --timeout=60s

echo "Entrando no pod: $POD"

kubectl exec -it $POD -- sh
