defmodule ChartsLive.Live.StackedBarLive.ChartComponent do
  @moduledoc """
  Stacked Bar Chart Component
  """

  use ChartsLive.ChartBehavior
  use Phoenix.LiveComponent

  alias Charts.Gradient
  alias Charts.StackedBarChart
  alias Charts.StackedColumnChart.Rectangle
  alias ChartsLive.StackedBarView

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
      <%= StackedBarView.legend(@rectangles, @chart.colors) %>
      <figure>
        <svg class="chart--hor-bar" aria-labelledby="chartTitle" role="group" width="100%" height={StackedBarView.viewbox_height(@rectangles)} style="overflow: visible;">
          <svg id={svg_id(@chart, "ylabels")} class="bar__y-labels" width="14%" height="92%" y="0" x="0">
            <%= for %Charts.StackedBarChart.MultiBar{label: label, height: height, offset: offset} <- Charts.StackedBarChart.rows(@chart) do %>
              <svg x="0" y={"#{offset}%"} height={"#{height}%"} width="100%">
                  <svg width="100%" height="100%">
                  <text x="50%" y="50%" font-size="10px" alignment-baseline="middle" text-anchor="middle"><%= label %></text>
                </svg>
              </svg>
            <% end %>
          </svg>

          <%= StackedBarView.x_axis_labels(@chart, @grid_lines, @offsetter, @x_axis_format) %>
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
end
