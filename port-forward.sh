#!/bin/bash

APP_LABEL="app=hello-k8s"
LOCAL_PORT=8080
REMOTE_PORT=8080
NAMESPACE=default

echo "🔍 Procurando Pod da aplicação..."

POD=$(kubectl get pods -n $NAMESPACE -l $APP_LABEL -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD" ]; then
  echo "❌ Nenhum pod encontrado com label $APP_LABEL"
  exit 1
fi

echo "✅ Pod encontrado: $POD"

echo "🚀 Iniciando port-forward"
echo "http://localhost:$LOCAL_PORT"

kubectl port-forward -n $NAMESPACE pod/$POD $LOCAL_PORT:$REMOTE_PORT
