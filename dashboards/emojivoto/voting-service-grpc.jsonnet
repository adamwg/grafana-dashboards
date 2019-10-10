local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local grpc = import 'templates/grpc.libsonnet';

dashboard.new(
  'Voting Service gRPC',
  tags=['emojivoto','grpc','voting-svc'],
  timezone='utc',
  schemaVersion=14,
  time_from='now-1h',
)
.addRows(
  grpc.new('Prometheus', 'emojivoto.v1.VotingService')
)
