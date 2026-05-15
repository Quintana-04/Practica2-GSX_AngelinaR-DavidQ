output "nginx_nodeport" {
  description = "NodePort to access the Nginx web server from outside the cluster"
  value       = kubernetes_service.nginx.spec[0].port[0].node_port
}

output "backend_service_name" {
  description = "Internal cluster DNS name for the backend service"
  value       = kubernetes_service.backend.metadata[0].name
}

output "image_deployed" {
  description = "Full image reference deployed for each service"
  value = {
    nginx   = "${var.dockerhub_user}/nginx-gsx:${var.image_tag}"
    backend = "${var.dockerhub_user}/python-gsx:${var.image_tag}"
  }
}
