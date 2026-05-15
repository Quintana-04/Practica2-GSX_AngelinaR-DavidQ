#!/bin/bash
echo "=== Week 11 - Verificación IaC ==="

echo -e "\n[1] Pods running:"
kubectl get pods

echo -e "\n[2] Services:"
kubectl get services

echo -e "\n[3] Nginx responde:"
curl -s http://192.168.49.2:30080 | grep -o "<title>.*</title>"

echo -e "\n[4] Backend responde:"
kubectl exec -it $(kubectl get pod -l app=backend -o jsonpath='{.items[0].metadata.name}') -- python3 -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8000').read().decode())"

echo -e "\n=== Todo OK ==="
