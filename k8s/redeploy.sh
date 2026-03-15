#!/bin/bash

DEPLOYMENT="hello-k8s"

echo "Restarting deployment..."

kubectl rollout restart deployment $DEPLOYMENT

kubectl rollout status deployment $DEPLOYMENT
