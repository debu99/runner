resource "kubernetes_namespace" "this" {
  for_each = var.namespaces
  metadata {
    name = each.value
  }
}

resource "kubernetes_secret" "gcs_secret" {
  metadata {
    name      = "google-application-credentials"
    namespace = var.namespaces["gitlab-runner"]
  }
  data = {
    "gcs-application-credentials-file" = module.service_account.key
  }
}

data "template_file" "gitlab_runner" {
  template = file("${path.module}/templates/gitlab-runner.tpl")
  vars = {
    gcs_bucket_name          = module.gcs_bucket.name
    gcs_service_account      = module.service_account.email
    gcs_secret_name          = kubernetes_secret.gcs_secret.metadata[0].name
    gitlab_runner_concurrent = var.gitlab_runner_concurrent
  }
}

resource "helm_release" "gitlab_runner" {
  name       = "gitlab-runner"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  namespace  = "gitlab-runner"

  values = [
    data.template_file.gitlab_runner.rendered
  ]

  set_sensitive {
    name  = "runnerRegistrationToken"
    value = var.runner_registration_token
  }

  depends_on = [
    kubernetes_namespace.this,
    module.gcs_bucket,
    kubernetes_secret.gcs_secret
  ]
}

resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  namespace  = "monitoring"

  depends_on = [
    kubernetes_namespace.this
  ]
}

resource "helm_release" "prometheus" {
  name       = "prometheus-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  values = [
    file("${path.module}/values/prometheus.yaml")
  ]

  depends_on = [
    kubernetes_namespace.this
  ]
}

locals {
  gitlab_runner_scale_threshold = var.gitlab_runner_concurrent - 1
}

data "template_file" "scaledobject" {
  template = file("${path.module}/templates/scaledobject.tpl")
  vars = {
    gitlab_runner_namespace       = var.namespaces["gitlab-runner"]
    gitlab_runner_min_replica     = var.gitlab_runner_min_replica
    gitlab_runner_max_replica     = var.gitlab_runner_max_replica
    gitlab_runner_scale_threshold = local.gitlab_runner_scale_threshold
  }
}

resource "kubectl_manifest" "scaledobject" {
  yaml_body = data.template_file.scaledobject.rendered

  depends_on = [
    kubernetes_namespace.this,
    helm_release.gitlab_runner,
    helm_release.keda,
    helm_release.prometheus,
    time_sleep.wait_30_seconds
  ]
}

resource "time_sleep" "wait_30_seconds" {
  depends_on       = [helm_release.keda]
  destroy_duration = "30s"
}
