defmodule ChartsLive.BarView do
  @moduledoc """
  View functions for rendering Bar charts
  """

  use ChartsLive.ChartBehavior

  alias Charts.Gradient

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
