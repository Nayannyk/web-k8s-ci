variable "namespace" { type = string default = "webapp-ns" }
variable "image"     { type = string default = "myusername/minikube-web:v1" }
variable "replicas"  { type = number default = 2 }

