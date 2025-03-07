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

resource "helm_release" "aws-load-balancer-controller" {
    name       = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    version    = "1.11.0"
    namespace  = "kube-system"
    create_namespace = true
    set = [
      {
        name  = "clusterName"
        value = module.eks.cluster_name
      },
      {
          name  = "region"
          value = local.region
      },
      {
        name  = "vpcId"
        value = module.vpc.vpc_id
      },
      {
        name  = "serviceAccount.create"
        value = "true"
      },
      {
        name  = "serviceAccount.name"
        value = "aws-load-balancer-controller"
      },
      {
        name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = module.aws-load-balancer-controller-role.iam_role_arn
      }
    ]
}