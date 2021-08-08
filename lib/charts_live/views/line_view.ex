defmodule ChartsLive.LineView do
  @moduledoc """
  View functions for rendering Line charts
  """

  use ChartsLive.ChartBehavior

  alias Charts.LineChart.{Line, Point}

  def svg_polyline_points([]), do: ""

  def svg_polyline_points(points) do
    points
    |> Enum.map(fn %Point{x_offset: x, y_offset: y} -> "#{10 * x},#{1000 - 10 * y}" end)
    |> List.insert_at(0, "#{hd(points).x_offset * 10},1000")
    |> List.insert_at(-1, "#{List.last(points).x_offset * 10},1000")
    |> Enum.join(" ")
  end

  @doc """
  The function used to generate X Axis labels
  """
  def x_axis_labels(chart, grid_lines, offsetter) do
    lines = Enum.map(grid_lines, &x_axis_column_label(&1, offsetter))

    content_tag(:svg, lines,
      id: svg_id(chart, "xlabels"),
      class: "lines__x-labels",
      width: "90%",
      height: "8%",
      y: "92%",
      x: "1%",
      style: "overflow: visible;",
      offset: "0"
    )
  end

  defp x_axis_column_label(line, offsetter) do
    content_tag(:svg,
      x: "#{offsetter.(line)}%",
      y: "0%",
      height: "100%",
      width: "20%",
      style: "overflow: visible;"
    ) do
      content_tag(:svg, width: "100%", height: "100%", x: "0", y: "0") do
        content_tag(:text, line,
          x: "50%",
          y: "50%",
          alignment_baseline: "middle",
          text_anchor: "middle"
        )
      end
    end
  end
end
