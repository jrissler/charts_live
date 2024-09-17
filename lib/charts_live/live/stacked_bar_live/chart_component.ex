defmodule ChartsLive.Live.StackedBarLive.ChartComponent do
  @moduledoc """
  Stacked Bar Chart Component
  """

  use ChartsLive.ChartBehavior

  use Phoenix.LiveComponent

  alias Charts.Gradient
  alias Charts.StackedBarChart
  alias Charts.StackedColumnChart.Rectangle

  def update(assigns, socket) do
    x_axis = assigns.chart.dataset.axes.magnitude_axis
    # Hardcode the number of steps to take as 10 for now
    grid_lines = x_axis.grid_lines.({x_axis.min, x_axis.max}, 5)

    grid_line_offsetter = fn grid_line ->
      result = 100 * grid_line / x_axis.max
      result
    end

    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:rows, StackedBarChart.rows(assigns.chart))
      |> assign(:rectangles, StackedBarChart.rectangles(assigns.chart))
      |> assign(:grid_lines, grid_lines)
      |> assign(:offsetter, grid_line_offsetter)
      |> assign(:x_axis_format, x_axis.format)
      |> assign(:x_axis_value_label, x_axis.label)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="lc-live-stacked-bar-component">
      <%= legend(@rectangles, @chart.colors) %>
      <figure>
        <svg class="chart--hor-bar" aria-labelledby="chartTitle" role="group" width="100%" height={viewbox_height(@rows)} style="overflow: visible;">
          <svg id={svg_id(@chart, "ylabels")} class="bar__y-labels" width="14%" height="92%" y="0" x="0">
            <%= for %Charts.StackedBarChart.MultiBar{label: label, height: height, offset: offset} <- Charts.StackedBarChart.rows(@chart) do %>
              <svg x="0" y={"#{offset}%"} height={"#{height}%"} width="100%">
                  <svg width="100%" height="100%">
                  <text x="50%" y="50%" font-size="10px" alignment-baseline="middle" text-anchor="middle"><%= label %></text>
                </svg>
              </svg>
            <% end %>
          </svg>

          <%= x_axis_labels(@chart, @grid_lines, @offsetter, @x_axis_format) %>
          <svg class="" width="84%" height="92%" x="14%" y="0">
            <g class="y-line">
              <line x1="0%" y1="0%" x2="0%" y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <line x1="0%" y1="100%" x2="100%" y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <%= for grid_line <- @grid_lines do %>
                <% offset = @offsetter.(grid_line) %>
                <line x1={"#{offset}%"} y1="0%" x2={"#{offset}%"} y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <% end %>
            </g>
            <svg id={svg_id(@chart, "results")} class="columns__results" width="100%" height="100%" viewBox="0 0 100 100" preserveAspectRatio="none">
              <g>
                <%= for %Rectangle{width: width, x_offset: x_offset, y_offset: y_offset, height: height, fill_color: fill_color, label: label} <- @rectangles do %>
                  <rect
                    x={"#{x_offset}"}
                    y={"#{y_offset}"}
                    height={"#{height / 2}"}
                    width={"#{width}"}
                    fill={"#{@chart.colors[fill_color]}"}
                    class="stacked-bar-rectangle"
                  >
                  <title><%= formatted_hover_text(label, @x_axis_format, @x_axis_value_label) %></title>
                  </rect>
                <% end %>
              </g>
            </svg>

          </svg>
          <%= color_defs(@chart) %>
        </svg>
      </figure>
    </div>
    """
  end

  defp viewbox_height(rows) do
    length(rows) * 16 + 170
  end

  defp x_axis_labels(chart, grid_lines, offsetter, label_format) do
    %{label: y_axis_label, appended_label: y_axis_appended_label} = axis_label(chart)
    lines = Enum.map(grid_lines, &x_axis_column_label(&1, offsetter, y_axis_label, y_axis_appended_label, label_format))

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
  defp legend(rectangles, colors) do
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
      content_tag(:dt, "", style: "background-color: #{colors[color_label]}; display: inline-block; height: 10px; width: 20px; vertical-align: middle;"),
      content_tag(:dd, color_to_label(color_label), style: "display: inline-block; margin: 0px 10px 0 6px; padding-bottom: 0;")
    ]
  end

  defp color_to_label(atom_color) do
    atom_color
    |> Atom.to_string()
    |> String.capitalize()
  end

  defp x_axis_column_label(line, offsetter, label, appended_label, label_format) do
    content_tag(:svg,
      x: "#{offsetter.(line)}%",
      y: "0%",
      height: "100%",
      width: "20%",
      style: "overflow: visible;"
    ) do
      content_tag(:svg, width: "100%", height: "100%", x: "0", y: "0") do
        content_tag(:text, "#{label}#{formatted_grid_line(line, label_format)}#{appended_label}",
          x: "50%",
          y: "50%",
          alignment_baseline: "middle",
          text_anchor: "start"
        )
      end
    end
  end
end
