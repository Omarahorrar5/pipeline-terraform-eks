#!/bin/bash

SERVICE_NAME="express-service"

MINIKUBE_IP=$(minikube ip)
NODE_PORT=$(kubectl get svc $SERVICE_NAME -o jsonpath='{.spec.ports[0].nodePort}')

echo "Calling app at http://$MINIKUBE_IP:$NODE_PORT"
echo "--------------------------------------------"

curl http://$MINIKUBE_IP:$NODE_PORT
echo