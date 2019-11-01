local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graph = grafana.graphPanel;
local row = grafana.row;

{
  new(datasource, service)::
    [
      row.new(
        title='Request Rates',
        height='300px',
      )
      .addPanels([
        graph.new(
          'Request Rate by Method',
          span=6,
          format='opm',
          fill=0,
          min=0,
          datasource=datasource,
          legend_values=true,
          legend_current=true,
          legend_avg=true,
          legend_hideZero=true,
          legend_rightSide=true,
          legend_alignAsTable=true,
        )
        .addTarget(
          prometheus.target(
            '60 * sum(rate(grpc_server_handled_total{grpc_service="%s"}[5m])) by (grpc_method)' % service,
            legendFormat='{{grpc_method}}',
          )
        ),
        graph.new(
          'Request Rate by Response Code',
          span=6,
          format='opm',
          fill=0,
          min=0,
          datasource=datasource,
          legend_values=true,
          legend_current=true,
          legend_avg=true,
          legend_hideZero=true,
          legend_rightSide=true,
          legend_alignAsTable=true,
        )
        .addTarget(
          prometheus.target(
            '60 * sum(rate(grpc_server_handled_total{grpc_service="%s"}[5m])) by (grpc_code)' % service,
            legendFormat='{{grpc_code}}',
          )
        ),
      ]),
      row.new(
        title='Error Rates',
        height='300px',
      )
      .addPanels([
        graph.new(
          'Total Error Rate',
          span=6,
          format='percentunit',
          fill=0,
          min=0,
          datasource=datasource,
          legend_values=true,
          legend_current=true,
          legend_avg=true,
          legend_rightSide=true,
          legend_alignAsTable=true,
        )
        .addTarget(
          prometheus.target(
            'sum(rate(grpc_server_handled_total{grpc_service="%s",grpc_code!="OK"}[5m])) / sum(rate(grpc_server_handled_total{grpc_service="%s"}[5m]))' % [service, service],
            legendFormat='Error Rate',
          )
        ),
        graph.new(
          'Error Rate by Method',
          span=6,
          format='percentunit',
          fill=0,
          min=0,
          datasource=datasource,
          legend_values=true,
          legend_current=true,
          legend_avg=true,
          legend_hideZero=true,
          legend_rightSide=true,
          legend_alignAsTable=true,
        )
        .addTarget(
          prometheus.target(
            'sum(rate(grpc_server_handled_total{grpc_service="%s",grpc_code!="OK"}[5m])) by (grpc_method) / sum(rate(grpc_server_handled_total{grpc_service="%s"}[5m])) by (grpc_method)' % [service, service],
            legendFormat='{{grpc_method}}',
          )
        ),
      ]),
      row.new(
        title='Request Durations',
        height='300px',
      )
      .addPanels([
        graph.new(
          'p50 Duration by Method',
          span=4,
          format='s',
          fill=0,
          min=0,
          datasource=datasource,
          legend_values=true,
          legend_current=true,
          legend_avg=true,
          legend_rightSide=true,
          legend_alignAsTable=true,
        )
        .addTarget(
          prometheus.target(
            'histogram_quantile(0.5, sum(rate(grpc_server_handling_seconds_bucket{grpc_service="%s"}[5m])) by (le, grpc_method))' % service,
            legendFormat='{{grpc_method}}',
          )
        ),
        graph.new(
          'p90 Duration by Method',
          span=4,
          format='s',
          fill=0,
          min=0,
          datasource=datasource,
          legend_values=true,
          legend_current=true,
          legend_avg=true,
          legend_rightSide=true,
          legend_alignAsTable=true,
        )
        .addTarget(
          prometheus.target(
            'histogram_quantile(0.90, sum(rate(grpc_server_handling_seconds_bucket{grpc_service="%s"}[5m])) by (le, grpc_method))' % service,
            legendFormat='{{grpc_method}}',
          )
        ),
        graph.new(
          'p99 Duration by Method',
          span=4,
          format='s',
          fill=0,
          min=0,
          datasource=datasource,
          legend_values=true,
          legend_current=true,
          legend_avg=true,
          legend_rightSide=true,
          legend_alignAsTable=true,
        )
        .addTarget(
          prometheus.target(
            'histogram_quantile(0.99, sum(rate(grpc_server_handling_seconds_bucket{grpc_service="%s"}[5m])) by (le, grpc_method))' % service,
            legendFormat='{{grpc_method}}',
          )
        ),
      ]),
    ],
}
