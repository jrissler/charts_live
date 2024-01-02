defmodule ChartsLive.Live.BarLive.ChartComponent do
  @moduledoc """
  Bar Chart Component
  """

  use ChartsLive.ChartBehavior
  use Phoenix.LiveComponent

  alias Charts.BarChart

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
        <svg class="chart--hor-bar" aria-labelledby="chartTitle" role="group" width="100%" height="100%" viewBox="0 0 600 400" style="overflow: visible;">
          <svg id={"#{svg_id(@chart, "bars")}"} width="100%" height="100%" viewBox="0 0 100 100" preserveAspectRatio="none">
            <%= for {bar, index} <- Enum.with_index(@bars) do %>
              <g class="bar">
                <path id={"#{index}"}
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
          <%= x_axis_labels(@chart, @grid_lines, @offsetter, @x_axis_format) %>
          <svg class="" width="90%" height="92%" x="10%" y="0">
            <g class="y-line">
              <line x1="0%" y1="0%" x2="0%" y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <line x1="0%" y1="100%" x2="100%" y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <%= for grid_line <- @grid_lines do %>
                <% offset = @offsetter.(grid_line) %>
                <line x1={"#{offset}%"} y1="0%" x2={"#{offset}%"} y2="100%" stroke="#efefef" stroke-width="2px" stroke-linecap="round" />
              <% end %>
            </g>
            <svg id={"#{svg_id(@chart, "bars")}"} width="100%" height="100%" viewBox="0 0 100 100" preserveAspectRatio="none">
              <%= for {bar, index} <- Enum.with_index(@bars) do %>
                <g class="bar">
                  <path id={"#{index}"}
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
          <%= color_defs(@chart) %>
        </svg>
      </figure>
    </div>
    """
  end

  defp x_axis_labels(chart, grid_lines, offsetter, label_format) do
    label = axis_label(chart)
    lines = Enum.map(grid_lines, &x_axis_column_label(&1, offsetter, label, label_format))

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
          text_anchor: "middle"
        )
      end
    end
  end
end
