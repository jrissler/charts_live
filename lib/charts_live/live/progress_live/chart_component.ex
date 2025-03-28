defmodule ChartsLive.Live.ProgressLive.ChartComponent do
  @moduledoc """
  Progress Component
  """

  use Phoenix.LiveComponent

  import ChartsLive.ChartHelpers

  alias Charts.Chart
  alias Charts.ProgressChart

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:data, ProgressChart.data(assigns.chart))
      |> assign(:progress, ProgressChart.progress(assigns.chart))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <figure data-testid="lc-live-progress-component">
      <svg id={svg_id(@chart, "chart")} class="counter" role="group" width="100%" height="100%" viewBox="0 0 42 42">
        <title><%= @chart.title %></title>

      <g id={svg_id(@chart, "circle")}>
        <circle class="counter__center" cx="21" cy="21" r="16" fill="transparent"></circle>
        <circle class="counter__ring" cx="21" cy="21" r="16" fill="transparent" stroke={color_to_fill(Chart.colors(@chart), @data.background_stroke_color)} stroke-width="5"></circle>

        <svg class="counter__label" width="100%" height="100%" y="0" x="0">
          <text x="50%" y="50%" fill={color_to_fill(Chart.colors(@chart), @data.percentage_text_fill_color)} font-size="10px" font-weight="100" font-family="sans-serif" alignment-baseline="middle" text-anchor="middle"><%= @progress %>%</text>
          <%= if @data.label do %>
            <text x="50%" y="62%" fill={color_to_fill(Chart.colors(@chart), @data.label_fill_color)} font-size="3px" font-weight="300" font-family="sans-serif" alignment-baseline="middle" text-anchor="middle"><%= @data.label %></text>
          <% end %>
          <%= if @data.secondary_label do %>
            <text x="50%" y="70%" fill={color_to_fill(Chart.colors(@chart), @data.label_fill_color)} font-size="2px" font-weight="300" font-family="sans-serif" alignment-baseline="middle" text-anchor="middle"><%= @data.secondary_label %></text>
          <% end %>
        </svg>

        <circle r="16" cx="21" cy="21" fill="transparent" stroke={color_to_fill(Chart.colors(@chart), :gray)} stroke-width="5" stroke-dasharray="565.48" stroke-dashoffset="0"></circle>

        <circle
            class="counter__value"
            cx="21"
            cy="21"
            r="16"
            fill="transparent"
            stroke={color_to_fill(Chart.colors(@chart), @data.percentage_fill_color)}
            style="transition: all 0.5s ease"
            stroke-width="5"
            stroke-dasharray={"#{@progress} #{100 - @progress}"}
            stroke-dashoffset="25"
            stroke-linecap="round">
            <animate attributeName="stroke-dasharray" values={" 0 100;#{@progress} #{100 - @progress}"} dur="1s" repeatCount="freeze" />
          </circle>
      </g>
      <.color_defs chart={@chart} />
      </svg>
    </figure>
    """
  end
end
