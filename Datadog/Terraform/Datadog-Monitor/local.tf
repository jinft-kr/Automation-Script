locals {

  cluster = {
    cluster_node_count = {
      name = "[GKE] {{kube_cluster_name.name}} 의 Node 개수 변경"
      type = "metric alert"
      query = "avg(last_5m):sum:kubernetes_state.node.count{kube_cluster_name:*} by {kube_cluster_name} > 2"
      message = var.slack_channel
      priority = 2
      critical = 2
      tags = []
    }
    cluster_error_event = {
      name = "[GKE] {{kube_cluster_name.name}} 에서 ERROR Event 발생"
      type = "event-v2 alert"
      query = "events(\"source:kubernetes kube_cluster_name:* status:error\").rollup(\"count\").by(\"kube_cluster_name\").last(\"5m\") > 1"
      message = var.slack_channel
      priority = 2
      critical = 1
      tags = []
    }
    cluster_all_pod_utilization = {
      name = "[GKE] {{cluster-name.name}} 의 전체 POD Utilization 75% 이상"
      type = "query alert"
      query = "avg(last_5m):(sum:kubernetes.pods.running{kube_cluster_name:*} by {cluster-name} / sum:kubernetes_state.node.pods_capacity{kube_cluster_name:*} by {cluster-name}) * 100 > 75"
      message = var.slack_channel
      priority = 2
      critical = 75
      tags = []
    }
    cluster_all_memory_utilization = {
      name = "[GKE] {{cluster-name.name}} 의 전체 Memory Utilization 75% 이상"
      type = "query alert"
      query = "avg(last_5m):(sum:kubernetes.memory.requests{kube_cluster_name:*} by {cluster-name} / sum:kubernetes_state.node.memory_allocatable{kube_cluster_name:*} by {cluster-name}) * 100 > 75"
      message = var.slack_channel
      priority = 2
      critical = 75
      tags = []
    }
    cluster_all_cpu_utilization = {
      name = "[GKE] {{cluster-name.name}} 의 전체 CPU Utilization 75% 이상"
      type = "query alert"
      query = "avg(last_5m):(sum:kubernetes.cpu.requests{kube_cluster_name:*} by {cluster-name} / sum:kubernetes_state.node.cpu_allocatable{kube_cluster_name:*} by {cluster-name}) * 100 > 75"
      message = var.slack_channel
      priority = 2
      critical = 75
      tags = []
    }
  }
  pod = {
    pod_crashloopbackoff = {
      name = "[GKE] {{cluster-name.name}} 의 {{service.name}} 에서 CrashLoopBackOff 가 발생"
      type = "query alert"
      query = "avg(last_5m):sum:kubernetes_state.container.waiting{*} by {service,cluster-name} > 1"
      message = var.slack_channel
      priority = 1
      critical = 1
      tags = []
    }
    pod_oomkillded = {
      name = "[GKE] {{cluster-name.name}} 의 {{pod_name.name}} 에서 OOMKillded 발생"
      type = "query alert"
      query = "avg(last_5m):sum:kubernetes.containers.state.terminated{kube_cluster_name:*,reason:oomkilled} by {pod_name,cluster-name} > 0"
      message = var.slack_channel
      priority = 1
      critical = 0
      tags = []
    }
    pod_restart = {
      name = "[GKE] - {{cluster_name.name}} - {{service.name}} 에서 Restart 발생"
      type = "query alert"
      query = "avg(last_5m):per_minute(sum:kubernetes_state.container.restarts{*} by {service,cluster_name}) > 0"
      message = var.slack_channel
      priority = 0
      critical = 0
      tags = []
    }
  }
}