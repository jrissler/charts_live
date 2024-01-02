defmodule ChartsLive.StackedBarView do
  @moduledoc """
  View functions for rendering Stacked Bar charts
  """

  use ChartsLive.ChartBehavior

  import PhoenixHTMLHelpers.Tag

  def viewbox_height(rectangles) do
    length(rectangles) * 12 + 170
  end

  @doc """
  The function used to generate X Axis labels
  """
  def x_axis_labels(chart, grid_lines, offsetter, label_format) do
    label = axis_label(chart)
    lines = Enum.map(grid_lines, &x_axis_column_label(&1, offsetter, label, label_format))

    content_tag(:svg, lines,
      id: svg_id(chart, "xlabels"),
      class: "lines__x-labels",
      width: "84%",
      height: "8%",
      y: "92%",
      x: "5%",
      style: "overflow: visible;",
      offset: "0"
    )
  end

  # TODO: add to behavior, shared with stacked column
  def legend(rectangles, colors) do
    legend_items =
      rectangles
      |> Enum.map(& &1.fill_color)
      |> Enum.uniq()
      |> Enum.map(&legend_content(&1, colors))
      |> Enum.reverse()

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

  defp x_axis_column_label(line, offsetter, label, label_format) do
    content_tag(:svg,
      x: "#{offsetter.(line)}%",
      y: "0%",
      height: "100%",
      width: "20%",
      style: "overflow: visible;"
    ) do
      content_tag(:svg, width: "100%", height: "100%", x: "0", y: "0") do
        content_tag(:text, "#{label}#{formatted_grid_line(line, label_format)}",
          x: "50%",
          y: "50%",
          alignment_baseline: "middle",
          text_anchor: "start"
        )
      end
    end
  end
end
