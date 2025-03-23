defmodule ChartsLive.Live.BarLive.ChartComponent do
  @moduledoc """
  Bar Chart Component
  """

  use Phoenix.LiveComponent

  import ChartsLive.ChartHelpers

  alias Charts.BarChart
  alias Charts.Chart

  def update(assigns, socket) do
    x_axis = assigns.chart.dataset.axes.magnitude_axis
    # Hardcode the number of steps to take as 10 for now
    grid_lines = x_axis.grid_lines.({x_axis.min, x_axis.max}, 10)

    grid_line_offsetter = fn grid_line ->
      result = 100 * grid_line / x_axis.max
      result
    end

    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:bars, BarChart.bars(assigns.chart))
      |> assign(:grid_lines, grid_lines)
      |> assign(:offsetter, grid_line_offsetter)
      |> assign(:x_axis_format, x_axis.format)
      |> assign(:x_axis_value_label, x_axis.label)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="lc-live-bar-component">
      <figure>
        <svg class="chart--hor-bar" role="group" width="100%" height={viewbox_height(@bars)} style="overflow: visible;">
          <svg id={svg_id(@chart, "ylabels")} class="bar__y-labels" width="14%" height="92%" y="0" x="0">
            <%= for %Charts.BarChart.Bar{label: label, height: height, offset: offset} <- Charts.BarChart.bars(@chart) do %>
              <svg x="0" y={"#{offset}%"} height={"#{height}%"} width="100%">
                  <svg width="100%" height="100%">
                  <text x="50%" y="50%" font-size="12px" alignment-baseline="middle" text-anchor="middle"><%= label %></text>
                </svg>
              </svg>
            <% end %>
          </svg>
          <.x_axis_labels chart={@chart} grid_lines={@grid_lines} offsetter={@offsetter} label_format={@x_axis_format} />
          <svg class="" width="84%" height="92%" x="14%" y="0">
            <g class="y-line">
              <line x1="0%" y1="0%" x2="0%" y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <line x1="0%" y1="100%" x2="100%" y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <%= for grid_line <- @grid_lines do %>
                <% offset = @offsetter.(grid_line) %>
                <line x1={"#{offset}%"} y1="0%" x2={"#{offset}%"} y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <% end %>
            </g>
            <svg id={"#{svg_id(@chart, "bars")}"} width="100%" height="100%" viewBox="0 0 100 100" preserveAspectRatio="none">
              <%= for {bar, _index} <- Enum.with_index(@bars) do %>
                <g class="bar">
                  <path
                    class="bar"
                    d={"
                      M0,#{bar.bar_offset},
                      h#{bar.bar_width}
                      q2,0 2,2
                      v#{bar.bar_height - 4}
                      q0,2 -2,2
                      h-#{bar.bar_width},
                      z
                    "}
                    fill={color_to_fill(Chart.colors(@chart), bar.fill_color)}
                    style="transition: all 1s ease;">
                      <animate attributeName="width" values="0%;30%" dur="1s" repeatCount="freeze" />
                      <title><%= formatted_hover_text(bar.value, @x_axis_format, @x_axis_value_label) %></title>
                  </path>
                </g>
              <% end %>
            </svg>
          </svg>
          <.color_defs chart={@chart} />
        </svg>
      </figure>
    </div>
    """
  end

  defp viewbox_height(bars) do
    length(bars) * 22 + 170
  end

  def x_axis_labels(assigns) do
    ~H"""
    <svg id={svg_id(@chart, "xlabels")} class="lines__x-labels" width="84%" height="8%" y="92%" x="5%" style="overflow: visible;" offset="0">
      <%= for line <- @grid_lines do %>
        <svg x={"#{@offsetter.(line)}%"} y="0%" height="100%" width="20%" style="overflow: visible;">
          <svg width="100%" height="100%" x="0" y="0">
            <text x="50%" y="50%" alignment_baseline="middle" text_anchor="middle">
              <%= "#{axis_label(@chart).label}#{formatted_grid_line(line, @label_format)}#{axis_label(@chart).appended_label}" %>
            </text>
          </svg>
        </svg>
      <% end %>
    </svg>
    """
  end
end
