resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.17.0"
  namespace  = "cert-manager"
  create_namespace = true
  values = [
    file("${path.module}/helm-values/cert-manager.yaml")
  ]
}

resource "helm_release" "ingress-nginx" {
    name       = "ingress-nginx"
    repository = "https://kubernetes.github.io/ingress-nginx"
    chart      = "ingress-nginx"
    version    = "4.12.0"
    namespace  = "ingress-nginx"
    create_namespace = true
    values = [
        file("${path.module}/helm-values/ingress-nginx.yaml")
    ]
}