terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# ─── ConfigMap ───────────────────────────────────────────────────────────────

resource "kubernetes_config_map" "gsx_config" {
  metadata {
    name = "gsx-config"
  }
  data = {
    python_port = tostring(var.backend_port)
    nginx_port  = tostring(var.nginx_port)
  }
}

# ─── Backend (Python app) ─────────────────────────────────────────────────────

resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend-deployment"
    labels = {
      app = "backend"
    }
  }
  spec {
    replicas = var.backend_replicas
    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        container {
          name  = "python-app"
          image = "${var.dockerhub_user}/python-gsx:${var.image_tag}"
          port {
            container_port = var.backend_port
          }
          env {
            name = "APP_PORT"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.gsx_config.metadata[0].name
                key  = "python_port"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend-service"
  }
  spec {
    selector = {
      app = "backend"
    }
    port {
      protocol    = "TCP"
      port        = var.backend_port
      target_port = var.backend_port
    }
  }
}

# ─── Nginx ────────────────────────────────────────────────────────────────────

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-deployment"
    labels = {
      app = "web-server"
    }
  }
  spec {
    replicas = var.nginx_replicas
    selector {
      match_labels = {
        app = "web-server"
      }
    }
    template {
      metadata {
        labels = {
          app = "web-server"
        }
      }
      spec {
        container {
          name  = "nginx-gsx"
          image = "${var.dockerhub_user}/nginx-gsx:${var.image_tag}"
          port {
            container_port = var.nginx_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "web-service"
  }
  spec {
    type = "NodePort"
    selector = {
      app = "web-server"
    }
    port {
      protocol    = "TCP"
      port        = var.nginx_port
      target_port = var.nginx_port
      node_port   = 30080
    }
  }
}
