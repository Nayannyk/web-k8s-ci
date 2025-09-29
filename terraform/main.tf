terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.1"
    }
  }
}

provider "kubernetes" {
  # uses KUBECONFIG env or default ~/.kube/config
}

resource "kubernetes_namespace" "webns" {
  metadata { name = var.namespace }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name      = "web-deploy"
    namespace = kubernetes_namespace.webns.metadata[0].name
    labels = { app = "webapp" }
  }

  spec {
    replicas = var.replicas
    selector { match_labels = { app = "webapp" } }

    template {
      metadata { labels = { app = "webapp" } }
      spec {
        container {
          name  = "web"
          image = var.image
          port { container_port = 80 }

          readiness_probe {
            http_get { path = "/" port = 80 }
            initial_delay_seconds = 5
            period_seconds = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "websvc" {
  metadata {
    name      = "web-service"
    namespace = kubernetes_namespace.webns.metadata[0].name
  }
  spec {
    selector = { app = "webapp" }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

# Ingress via yaml file (Terraform ingress resources vary by provider version)
resource "kubernetes_manifest" "web_ingress" {
  manifest = yamldecode(file("${path.module}/../k8s/ingress.yaml"))
}

