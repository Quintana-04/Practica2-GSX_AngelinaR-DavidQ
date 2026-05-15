variable "dockerhub_user" {
  description = "Docker Hub username where images are hosted"
  type        = string
  default     = "quinti04"
}

variable "image_tag" {
  description = "Image tag to deploy (e.g. v1, latest, or a commit SHA from CI)"
  type        = string
  default     = "v1"
}

variable "backend_replicas" {
  description = "Number of replicas for the Python backend"
  type        = number
  default     = 1
}

variable "nginx_replicas" {
  description = "Number of replicas for the Nginx web server"
  type        = number
  default     = 1
}

variable "backend_port" {
  description = "Port exposed by the Python backend container"
  type        = number
  default     = 8000
}

variable "nginx_port" {
  description = "Port exposed by the Nginx container"
  type        = number
  default     = 80
}
