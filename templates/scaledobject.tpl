apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: gitlab-runner
  namespace: ${gitlab_runner_namespace}
spec:
  scaleTargetRef:
    kind: Deployment
    name: gitlab-runner
  pollingInterval: 30
  cooldownPeriod:  60
  minReplicaCount: ${gitlab_runner_min_replica}
  maxReplicaCount: ${gitlab_runner_max_replica}
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus-operator-prometheus.monitoring.svc.cluster.local:9090
      metricName: gitlab_runner_jobs
      threshold: "${gitlab_runner_scale_threshold}"
      query: sum(gitlab_runner_jobs{state="running"})