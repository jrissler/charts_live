defmodule ChartsLive.StackedColumnView do
  @moduledoc """
  View functions for rendering Stacked Column charts
  """

  use ChartsLive.ChartBehavior

  alias Charts.Gradient
  alias Charts.StackedColumnChart.Rectangle

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
