#!/bin/bash

IMAGE_NAME=hello-k8s
VERSION=0.0.1

echo "🔨 Buildando imagem..."
docker build -t ${IMAGE_NAME}:${VERSION} .

echo "🏷️  Tag latest..."
docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest

echo "✅ Build finalizado!"
