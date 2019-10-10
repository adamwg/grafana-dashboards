local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local grpc = import 'templates/grpc.libsonnet';

dashboard.new(
  'Emoji Service gRPC',
  tags=['emojivoto','grpc','emoji-svc'],
  timezone='utc',
  schemaVersion=14,
  time_from='now-1h',
)
.addRows(
  grpc.new('Prometheus', 'emojivoto.v1.EmojiService')
)
