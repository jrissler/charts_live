defmodule ChartsLive.Live.StackedColumnLive.ChartComponent do
  @moduledoc """
  Stacked Bar Chart Component
  """

  use ChartsLive.ChartBehavior
  use Phoenix.LiveComponent

  alias Charts.Gradient
  alias Charts.StackedColumnChart
  alias Charts.StackedColumnChart.Rectangle
  alias ChartsLive.StackedColumnView

  def update(assigns, socket) do
    y_axis = assigns.chart.dataset.axes.magnitude_axis
    # Hardcode the number of steps to take as 10 for now
    grid_lines = y_axis.grid_lines.({y_axis.min, y_axis.max}, 10)
    grid_line_offsetter = fn grid_line -> 100 * (y_axis.max - grid_line) / y_axis.max end

    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:columns, StackedColumnChart.columns(assigns.chart))
      |> assign(:rectangles, StackedColumnChart.rectangles(assigns.chart))
      |> assign(:grid_lines, grid_lines)
      |> assign(:grid_line_offsetter, grid_line_offsetter)
      |> assign(:y_axis_format, y_axis.format)
      |> assign(:y_axis_value_label, y_axis.label)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="lc-live-stacked-bar-component">
      <%= StackedColumnView.legend(@rectangles, @chart.colors) %>
      <figure>
        <svg id={svg_id(@chart, "chart")} class="columns__chart" aria-labelledby="chartTitle" role="group" width="100%" height="100%" viewBox="0 0 700 400">
          <%= y_axis_labels(@chart, @grid_lines, @grid_line_offsetter, @y_axis_format) %>
          <%= StackedColumnView.x_axis_labels(@chart, @columns) %>

          <svg id={svg_id(@chart, "graph")} class="columns__graph" width="90%" height="92%" x="10%" y="0">
            <%= x_axis_background_lines(@chart, @grid_lines, @grid_line_offsetter) %>
            <svg id={svg_id(@chart, "results")} class="columns__results" width="100%" height="100%" viewBox="0 0 100 100" preserveAspectRatio="none">
              <g>
                <%= for %Rectangle{width: width, x_offset: x_offset, y_offset: y_offset, height: height, fill_color: fill_color, label: label} <- @rectangles do %>
                  <rect
                    x={x_offset}
                    y={y_offset}
                    height={height}
                    width={width / 2}
                    fill={@chart.colors[fill_color]}
                  >
                  <title><%= formatted_hover_text(label, @y_axis_format, @y_axis_value_label) %></title>
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
end
