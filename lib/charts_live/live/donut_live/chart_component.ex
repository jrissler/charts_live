defmodule ChartsLive.Live.DonutLive.ChartComponent do
  @moduledoc """
  Donut Chart Component
  """

  use ChartsLive.ChartBehavior
  use Phoenix.LiveComponent

  alias Charts.DonutChart
  alias Charts.DonutChart.DonutSlice

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:slices, DonutChart.slices(assigns.chart))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <figure>
      <div class="lc-live-donut-component">
        <svg id={svg_id(@chart, "chart")} class="donut" aria-labelledby="chartTitle" role="group" width="100%" height="100%" viewBox="0 0 42 42">

          <!-- background -->
          <circle class="donut-hole" cx="21" cy="21" r="15.91549430918954" fill="#fff" role="presentation" pointer-events="none;"></circle>
          <circle class="donut-ring" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#d2d3d4" stroke-width="3" role="presentation" pointer-events="none;"></circle>

          <%= for %DonutSlice{value: value, label: label, fill_color: fill_color, stroke_dasharray: stroke_dasharray, stroke_dashoffset: stroke_dashoffset} <- @slices do %>
            <g>
              <circle class="donut-segment" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke={color_to_fill(@chart.colors(), fill_color)} stroke-width="3" stroke-dasharray={stroke_dasharray} stroke-dashoffset={stroke_dashoffset} aria-labelledby={"donut-segment-#{value}-title donut-segment-#{value}-desc"} pointer-events="visibleStroke">
              <title><%= label %></title>
              </circle>
            </g>
          <% end %>

          <g class="chart-text">
            <text x="50%" y="50%" class="chart-number">
              <%= total(@chart.dataset.data) %>
            </text>
            <text x="50%" y="50%" class="chart-label">
              <%= @chart.title %>
            </text>
          </g>
          <%= color_defs(@chart) %>
        </svg>
      </div>

      <figcaption class="figure-key">
        <ul class="figure-key-list" aria-hidden="true" role="presentation">
          <%= for %DonutSlice{label: label, fill_color: fill_color} <- @slices do %>
            <li phx-click="chart-legend-select" phx-value-legend-selected-label={label}>
              <span class="shape-circle" style={figure_color(@chart.colors(), fill_color)}></span>
              <%= label %>
            </li>
          <% end %>
        </ul>
      </figcaption>
    </figure>
    """
  end

  defp total(data) do
    data
    |> Enum.map(&hd(&1.values))
    |> Enum.sum()
  end

  defp figure_color(colors, name) do
    case Map.get(colors, name) do
      %Gradient{start_color: start_color, end_color: end_color} ->
        "background: linear-gradient(#{start_color}, #{end_color});"

      value ->
        "background-color: #{value}"
    end
  end
end
