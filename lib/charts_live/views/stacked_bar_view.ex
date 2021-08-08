defmodule ChartsLive.StackedBarView do
  @moduledoc """
  View functions for rendering Stacked Bar charts
  """

  use ChartsLive.ChartBehavior

  alias Charts.Gradient
  alias Charts.StackedColumnChart.Rectangle

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

  def legend(rectangles, colors) do
    legend_items =
      rectangles
      |> Enum.map(& &1.fill_color)
      |> Enum.uniq()
      |> Enum.reverse()
      |> Enum.map(&legend_content(&1, colors))

    content_tag(:dl, legend_items, style: "margin-left: 10%; float: right;")
  end

  defp legend_content(color_label, colors) do
    [
      content_tag(:dt, "",
        style:
          "background-color: #{colors[color_label]}; display: inline-block; height: 10px; width: 20px; vertical-align: middle;"
      ),
      content_tag(:dd, color_to_label(color_label),
        style: "display: inline-block; margin: 0px 10px 0 6px; padding-bottom: 0;"
      )
    ]
  end

  defp color_to_label(atom_color) do
    atom_color
    |> Atom.to_string()
    |> String.capitalize()
  end
end
