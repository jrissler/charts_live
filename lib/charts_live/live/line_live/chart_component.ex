defmodule ChartsLive.Live.LineLive.ChartComponent do
  @moduledoc """
  Line Chart Component
  """

  use ChartsLive.ChartBehavior
  use Phoenix.LiveComponent

  alias Charts.LineChart
  alias Charts.LineChart.Line
  alias Charts.LineChart.Point

  def update(assigns, socket) do
    x_axis = assigns.chart.dataset.axes.x
    y_axis = assigns.chart.dataset.axes.y
    # # Hardcode the number of steps to take as 5 for now
    x_grid_lines = x_axis.grid_lines.({x_axis.min, x_axis.max}, 5)
    x_grid_line_offsetter = fn grid_line -> 100 * grid_line / x_axis.max end

    y_grid_lines = y_axis.grid_lines.({y_axis.min, y_axis.max}, 5)
    y_grid_line_offsetter = fn grid_line -> 100 * (y_axis.max - grid_line) / y_axis.max end

    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:points, LineChart.points(assigns.chart))
      |> assign(:lines, LineChart.lines(assigns.chart))
      |> assign(:x_grid_lines, x_grid_lines)
      |> assign(:x_grid_line_offsetter, x_grid_line_offsetter)
      |> assign(:y_grid_lines, y_grid_lines)
      |> assign(:y_grid_line_offsetter, y_grid_line_offsetter)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <figure class="lc-live-line-component">
      <svg id={svg_id(@chart, "chart")} class="line__chart" aria-labelledby="chartTitle" role="group" width="100%" height="100%" viewBox="0 0 700 400" style="overflow: visible;">
        <title id="chartTitle"><%= Chart.title(@chart) %></title>

        <%= y_axis_labels(@chart, @y_grid_lines, @y_grid_line_offsetter) %>
        <%= x_axis_labels(@chart, @x_grid_lines, @x_grid_line_offsetter) %>

        <svg id={svg_id(@chart, "graph")} class="line__graph" width="90%" height="92%" x="10%" y="0">
          <g id="chart-lines" class="line__lines">
            <g class="y-line">
              <line x1="0%" y1="0%" x2="0%" y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <line x1="0%" y1="100%" x2="100%" y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <%= for grid_line <- @x_grid_lines do %>
              <% offset = @x_grid_line_offsetter.(grid_line) %>
              <line x1={"#{offset}%"} y1="0%" x2={"#{offset}%"} y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <% end %>
            </g>
            <%= x_axis_background_lines(@chart, @x_grid_lines, @x_grid_line_offsetter) %>
            <%= for %Line{start: %{x_offset: x1, y_offset: y1}, end: %{x_offset: x2, y_offset: y2}} <- @lines do %>
              <line
                x1={"#{x1}%"}
                y1={"#{100 - y1}%"}
                x2={"#{x2}%"}
                y2={"#{100 - y2}%"}
                stroke="#efefef"
                stroke-width="2px"
                stroke-linecap="round"
              />
            <% end %>
          </g>

          <svg id={svg_id(@chart, "results")} class="line__results" width="100%" height="100%" x="0%" y="0%">
            <svg width='100%' height='100%' viewBox="0 0 1000 1000" preserveAspectRatio="none">
              <g id={svg_id(@chart, "lines")}>
                <polyline fill="url(#grad)" stroke="url(#blue_gradient)" style="transition: all 1s ease;" stroke-width="0" points={svg_polyline_points(@points)}>
                </polyline>
              </g>
            </svg>
            <g id={svg_id(@chart, "dots")} class="line_dots">
              <%= for %Point{x_offset: x_offset, y_offset: y_offset, fill_color: fill_color} <- @points do %>
                <circle
                  fill={color_to_fill(@chart.colors(), fill_color)}
                  cx={"#{x_offset}%"}
                  cy={"#{100 - y_offset}%"}
                  r="6">
                  <animate attributeName="cx" values="0;#{x_offset" dur="0.5s" repeatCount="freeze" />
                </circle>
              <% end %>
            </g>
          </svg>

          <linearGradient id="grad" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:rgba(54, 209, 220, .5);stop-opacity:1"></stop>
            <stop offset="100%" style="stop-color:white;stop-opacity:0"></stop>
          </linearGradient>
          <%= color_defs(@chart) %>
        </svg>
      </svg>
    </figure>
    """
  end

  defp svg_polyline_points([]), do: ""

  defp svg_polyline_points(points) do
    points
    |> Enum.map(fn %Point{x_offset: x, y_offset: y} -> "#{10 * x},#{1000 - 10 * y}" end)
    |> List.insert_at(0, "#{hd(points).x_offset * 10},1000")
    |> List.insert_at(-1, "#{List.last(points).x_offset * 10},1000")
    |> Enum.join(" ")
  end

  defp x_axis_labels(chart, grid_lines, offsetter) do
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
