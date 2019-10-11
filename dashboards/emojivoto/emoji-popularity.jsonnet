local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local prometheus = grafana.prometheus;
local graph = grafana.graphPanel;
local table = grafana.tablePanel;

local tableStyles = [
  # Hide the time column.
  {
    alias: 'Time',
    pattern: 'Time',
    type: 'hidden',
  },
  # Rename Metric -> Emoji and format it as a string.
  {
    alias: 'Emoji',
    pattern: 'Metric',
    type: 'string',
  },
  # Rename Value -> Votes and format it as an integer.
  {
    alias: 'Votes',
    pattern: 'Value',
    type: 'number',
    unit: 'locale',
    decimals: 0,
  },
];

# Sort the table by votes.
local tableSort = {
  sort: {
    col: 2,
    desc: true,
  }
};

dashboard.new(
  'Emoji Popularity',
  tags=['emojivoto'],
  timezone='utc',
  schemaVersion=16,
  time_from='now-1h',
)
.addPanel(
  graph.new(
    'Emoji Popularity Over Time',
    format='opm',
    fill=0,
    min=0,
    datasource='Prometheus',
    legend_rightSide=true,
    legend_alignAsTable=true,
    legend_values=true,
    legend_current=true,
    legend_max=true,
    legend_min=true,
    legend_hideZero=true,
    legend_sort='current',
    legend_sortDesc=true,
  )
  .addTarget(
    prometheus.target(
      '60*sum(rate(emojivoto_votes_total[5m])) by (emoji)',
      legendFormat='{{emoji}}',
    )
  ),
  gridPos={x: 0, y: 0, w: 24, h: 10}
)
.addPanel(
  table.new(
    'Top 20 Emojis (last 24h)',
    datasource='Prometheus',
    styles=tableStyles,
  )
  .addTarget(
    prometheus.target(
      'topk(20, sum(increase(emojivoto_votes_total[24h])) by (emoji))',
      legendFormat='{{emoji}}',
      instant=true,
    )
  ) + tableSort,
  gridPos={x: 0, y: 1, w: 12, h: 20}
)
.addPanel(
  table.new(
    'Top 20 Emojis (all time)',
    datasource='Prometheus',
    styles=tableStyles,
  )
  .addTarget(
    prometheus.target(
      'topk(20, sum(emojivoto_votes_total) by (emoji))',
      legendFormat='{{emoji}}',
      instant=true,
    )
  ) + tableSort,
  gridPos={x: 12, y: 1, w: 12, h: 20}
)
