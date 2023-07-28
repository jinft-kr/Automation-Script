resource "datadog_monitor" "pod_crashloopbackoff" {
  # 모니터 이름
  name = local.pod.pod_crashloopbackoff.name
  # 모니터 유형
  type = local.pod.pod_crashloopbackoff.type
  # 모니터 쿼리
  query = local.pod.pod_crashloopbackoff.query
  # 새 그룹에 대한 평가 지연 시간
  new_group_delay = 60
  # 모니터 평가 전 전체 데이터가 필요한지 여부
  require_full_window = false

  # 모니터 알림에 포함할 메세지 내용
  message = local.pod.pod_crashloopbackoff.message
  # 모니터 알림에 전송될 내용 (show_all/hide_query/hide_handles/hide_all)
  notification_preset_name = "hide_all"
  # 데이터 보고가 중지될 때 알림 여부
  notify_no_data = true
  # 태그가 지정된 사용자에게 모니터의 변경사항 알림 여부
  notify_audit = true

  # 모니터 경고의 심각도(1~5)
  priority = local.pod.pod_crashloopbackoff.priority

  # 모니터 경고 임계값
  monitor_thresholds {
    critical = local.pod.pod_crashloopbackoff.critical
  }

  # 모니터와 연결할 태그 목록
  tags = local.pod.pod_crashloopbackoff.tags
}
resource "datadog_monitor" "pod_oomkillded" {
  # 모니터 이름
  name = local.pod.pod_oomkillded.name
  # 모니터 유형
  type = local.pod.pod_oomkillded.type
  # 모니터 쿼리
  query = local.pod.pod_oomkillded.query
  # 새 그룹에 대한 평가 지연 시간
  new_group_delay = 60
  # 모니터 평가 전 전체 데이터가 필요한지 여부
  require_full_window = false

  # 모니터 알림에 포함할 메세지 내용
  message = local.pod.pod_oomkillded.message
  # 모니터 알림에 전송될 내용 (show_all/hide_query/hide_handles/hide_all)
  notification_preset_name = "hide_all"
  # 데이터 보고가 중지될 때 알림 여부
  notify_no_data = true
  # 태그가 지정된 사용자에게 모니터의 변경사항 알림 여부
  notify_audit = true

  # 모니터 경고의 심각도(1~5)
  priority = local.pod.pod_oomkillded.priority

  # 모니터 경고 임계값
  monitor_thresholds {
    critical = local.pod.pod_oomkillded.critical
  }

  # 모니터와 연결할 태그 목록
  tags = local.pod.pod_oomkillded.tags
}
resource "datadog_monitor" "pod_restart" {
  # 모니터 이름
  name = local.pod.pod_restart.name
  # 모니터 유형
  type = local.pod.pod_restart.type
  # 모니터 쿼리
  query = local.pod.pod_restart.query
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
  priority = local.pod.pod_restart.priority

  # 모니터 경고 임계값
  monitor_thresholds {
    critical = local.pod.pod_restart.critical
  }

  # 모니터와 연결할 태그 목록
  tags = local.pod.pod_restart.tags
}