defmodule ChartsLive.ColumnView do
  @moduledoc """
  View functions for rendering Column charts
  """

  use ChartsLive.ChartBehavior

  alias Charts.Gradient
  alias Charts.ColumnChart.Column

  @doc """
  The function used to generate X Axis labels
  """
  def x_axis_labels(chart, columns) do
    columns = Enum.map(columns, &x_axis_column_label(&1))

    content_tag(:svg, columns,
      id: svg_id(chart, "xlabels"),
      class: "columns__x-labels",
      width: "90.5%",
      height: "8%",
      y: "92%",
      x: "9.5%"
    )
  end

  defp x_axis_column_label(column) do
    content_tag(:svg, x: "#{column.offset}%", y: "0%", height: "100%", width: "#{column.width}%") do
      content_tag(:svg, width: "100%", height: "100%") do
        content_tag(:text, column.label,
          x: "50%",
          y: "50%",
          alignment_baseline: "middle",
          text_anchor: "middle"
        )
      end
    end
  end
end
