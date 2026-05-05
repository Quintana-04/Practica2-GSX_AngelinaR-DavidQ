from http.server import SimpleHTTPRequestHandler, HTTPServer

# Definimos cómo responde el servidor
class MyHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        # Este es el mensaje que veremos al hacer el curl
        self.wfile.write(b"Hello from container - GreenDevCorp Python App")

print("Servidor de GreenDevCorp escuchando en el puerto 8000...")
server = HTTPServer(('0.0.0.0', 8000), MyHandler)
server.serve_forever()
