fullnameOverride: gitlab-runner
replicas: 1

gitlabUrl: https://gitlab.com/

concurrent: ${gitlab_runner_concurrent}
checkInterval: 30

logLevel: info

rbac:
  create: true
  serviceAccountName: gitlab-runner
  clusterWideAccess: false
  serviceAccountAnnotations:
    iam.gke.io/gcp-service-account: ${gcs_service_account}

runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        namespace = "{{.Release.Namespace}}"
        image = "ubuntu:16.04"
  privileged: true
  tags: "dev"
  runUntagged: true
  requestConcurrency: 10
  serviceAccountName: gitlab-runner

  cache: 
    cacheType: gcs
    cachePath: "gitlab_runner"
    cacheShared: true
    gcsBucketName: ${gcs_bucket_name}
    secretName: ${gcs_secret_name}

metrics:
  enabled: true
  port: 9252
  serviceMonitor:
    enabled: true
    labels:
      monitoring: prometheus-operator
service:
  enabled: true
