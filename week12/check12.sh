#!/bin/bash
echo "=== Week 12 - Verificación NetworkPolicies ==="

echo -e "\n[1] NetworkPolicies activas:"
kubectl get networkpolicies

echo -e "\n[2] Tráfico externo → Nginx (debe responder):"
curl -s http://192.168.49.2:30080 | grep -o "<title>.*</title>"

echo -e "\n[3] Nginx → Backend (debe responder):"
kubectl exec -it $(kubectl get pod -l app=web-server -o jsonpath='{.items[0].metadata.name}') -- curl -s http://backend-service:8000

echo -e "\n[4] Backend → Exterior (debe fallar/timeout - segmentación funciona):"
kubectl exec $(kubectl get pod -l app=backend -o jsonpath='{.items[0].metadata.name}') -- python3 -c "
import urllib.request, socket
socket.setdefaulttimeout(3)
try:
    urllib.request.urlopen('http://192.168.49.2:30080')
    print('FALLO: conexión permitida (no debería)')
except Exception as e:
    print('OK: conexión bloqueada -', type(e).__name__)
"

echo -e "\n=== Verificación completada ==="
