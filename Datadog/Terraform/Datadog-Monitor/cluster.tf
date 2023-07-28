resource "datadog_monitor" "cluster_node_count" {
  # 모니터 이름
  name = local.cluster.cluster_node_count.name
  # 모니터 유형
  type = local.cluster.cluster_node_count.type
  # 모니터 쿼리
  query = local.cluster.cluster_node_count.query
  # 새 그룹에 대한 평가 지연 시간
  new_group_delay = 60
  # 모니터 평가 전 전체 데이터가 필요한지 여부
  require_full_window = false

  # 모니터 알림에 포함할 메세지 내용
  message = local.cluster.cluster_node_count.message
  # 모니터 알림에 전송될 내용 (show_all/hide_query/hide_handles/hide_all)
  notification_preset_name = "hide_all"
  # 데이터 보고가 중지될 때 알림 여부
  notify_no_data = true
  # 태그가 지정된 사용자에게 모니터의 변경사항 알림 여부
  notify_audit = true

  # 모니터 경고의 심각도(1~5)
  priority = local.cluster.cluster_node_count.priority

  # 모니터 경고 임계값
  monitor_thresholds {
    critical = local.cluster.cluster_node_count.critical
  }

  # 모니터와 연결할 태그 목록
  tags = local.cluster.cluster_node_count.tags
}

resource "datadog_monitor" "cluster_error_event" {
  # 모니터 이름
  name = local.cluster.cluster_error_event.name
  # 모니터 유형
  type = local.cluster.cluster_error_event.type
  # 모니터 쿼리
  query = local.cluster.cluster_error_event.query

  # 새 그룹에 대한 평가 지연 시간
  new_group_delay = 60
  # 모니터 평가 전 전체 데이터가 필요한지 여부
  require_full_window = false

  # 모니터 알림에 포함할 메세지 내용
  message = local.slack_channel.devops_monitoring
  # 모니터 알림에 전송될 내용 (show_all/hide_query/hide_handles/hide_all)
  notification_preset_name = "hide_all"
  # 데이터 보고가 중지될 때 알림 여부
  notify_no_data = true
  # 태그가 지정된 사용자에게 모니터의 변경사항 알림 여부
  notify_audit = true

  # 모니터 경고의 심각도(1~5)
  priority = local.cluster.cluster_error_event.priority

  # 모니터 경고 임계값
  monitor_thresholds {
    critical = local.cluster.cluster_error_event.critical
  }

  # 모니터와 연결할 태그 목록
  tags = local.cluster.cluster_error_event.tags
}
resource "datadog_monitor" "cluster_all_pod_utilization" {
  # 모니터 이름
  name = local.cluster.cluster_all_pod_utilization.name
  # 모니터 유형
  type = local.cluster.cluster_all_pod_utilization.type
  # 모니터 쿼리
  query = local.cluster.cluster_all_pod_utilization.query
  # 새 그룹에 대한 평가 지연 시간
  new_group_delay = 60
  # 모니터 평가 전 전체 데이터가 필요한지 여부
  require_full_window = false

  # 모니터 알림에 포함할 메세지 내용
  message = local.cluster.cluster_all_pod_utilization.message
  # 모니터 알림에 전송될 내용 (show_all/hide_query/hide_handles/hide_all)
  notification_preset_name = "hide_all"
  # 데이터 보고가 중지될 때 알림 여부
  notify_no_data = true
  # 태그가 지정된 사용자에게 모니터의 변경사항 알림 여부
  notify_audit = true

  # 모니터 경고의 심각도(1~5)
  priority = local.cluster.cluster_all_pod_utilization.priority

  # 모니터 경고 임계값
  monitor_thresholds {
    critical = local.cluster.cluster_all_pod_utilization.critical
  }

  # 모니터와 연결할 태그 목록
  tags = local.cluster.cluster_all_pod_utilization.tags
}
resource "datadog_monitor" "cluster_all_memory_utilization" {
  # 모니터 이름
  name = local.cluster.cluster_all_memory_utilization.name
  # 모니터 유형
  type = local.cluster.cluster_all_memory_utilization.type
  # 모니터 쿼리
  query = local.cluster.cluster_all_memory_utilization.query
  # 새 그룹에 대한 평가 지연 시간
  new_group_delay = 60
  # 모니터 평가 전 전체 데이터가 필요한지 여부
  require_full_window = false

  # 모니터 알림에 포함할 메세지 내용
  message = local.cluster.cluster_all_memory_utilization.message
  # 모니터 알림에 전송될 내용 (show_all/hide_query/hide_handles/hide_all)
  notification_preset_name = "hide_all"
  # 데이터 보고가 중지될 때 알림 여부
  notify_no_data = true
  # 태그가 지정된 사용자에게 모니터의 변경사항 알림 여부
  notify_audit = true

  # 모니터 경고의 심각도(1~5)
  priority = local.cluster.cluster_all_memory_utilization.priority

  # 모니터 경고 임계값
  monitor_thresholds {
    critical = local.cluster.cluster_all_memory_utilization.critical
  }

  # 모니터와 연결할 태그 목록
  tags = local.cluster.cluster_all_memory_utilization.tags
}
resource "datadog_monitor" "cluster_all_cpu_utilization" {
  # 모니터 이름
  name = local.cluster.cluster_all_cpu_utilization.name
  # 모니터 유형
  type = local.cluster.cluster_all_cpu_utilization.type
  # 모니터 쿼리
  query = local.cluster.cluster_all_cpu_utilization.query
  # 새 그룹에 대한 평가 지연 시간
  new_group_delay = 60
  # 모니터 평가 전 전체 데이터가 필요한지 여부
  require_full_window = false

  # 모니터 알림에 포함할 메세지 내용
  message = local.cluster.cluster_all_cpu_utilization.message
  # 모니터 알림에 전송될 내용 (show_all/hide_query/hide_handles/hide_all)
  notification_preset_name = "hide_all"
  # 데이터 보고가 중지될 때 알림 여부
  notify_no_data = true
  # 태그가 지정된 사용자에게 모니터의 변경사항 알림 여부
  notify_audit = true

  # 모니터 경고의 심각도(1~5)
  priority = local.cluster.cluster_all_cpu_utilization.priority

  # 모니터 경고 임계값
  monitor_thresholds {
    critical = local.cluster.cluster_all_cpu_utilization.critical
  }

  # 모니터와 연결할 태그 목록
  tags = local.cluster.cluster_all_cpu_utilization.tags
}