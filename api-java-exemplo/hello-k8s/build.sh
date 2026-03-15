#!/bin/bash

IMAGE_NAME=hello-k8s
VERSION=0.1.0
CLUSTER_NAME="lab-cluster"

echo "🔨 Buildando imagem..."
docker build -t ${IMAGE_NAME}:${VERSION} .

echo "🏷️  Tag latest..."
docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest

kind load docker-image ${IMAGE_NAME}:${VERSION} --name $CLUSTER_NAME

kubectl rollout restart deployment hello-k8s

docker images

echo "✅ Build finalizado!"
