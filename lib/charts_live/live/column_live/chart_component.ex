defmodule ChartsLive.Live.ColumnLive.ChartComponent do
  @moduledoc """
  Bar Chart Component
  """

  use ChartsLive.ChartBehavior
  use Phoenix.LiveComponent

  alias Charts.ColumnChart
  alias Charts.ColumnChart.Column
  alias Charts.Gradient

  def update(assigns, socket) do
    y_axis = assigns.chart.dataset.axes.magnitude_axis
    # Hardcode the number of steps to take as 5 for now
    grid_lines = y_axis.grid_lines.({y_axis.min, y_axis.max}, 5)
    grid_line_offsetter = fn grid_line -> 100 * (y_axis.max - grid_line) / y_axis.max end

    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:columns, ColumnChart.columns(assigns.chart))
      |> assign(:grid_lines, grid_lines)
      |> assign(:grid_line_offsetter, grid_line_offsetter)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="lc-live-column-component">
      <figure>
        <svg id={svg_id(@chart, "chart")} class="columns__chart" aria-labelledby="chartTitle" role="group" width="100%" height="100%" viewBox="0 0 700 400">
          <title id="chartTitle"><%= Chart.title(@chart) %></title>
          <%= y_axis_labels(@chart, @grid_lines, @grid_line_offsetter) %>
          <%= x_axis_labels(@chart, @columns) %>

          <svg id={svg_id(@chart, "graph")} class="columns__graph" width="90%" height="92%" x="10%" y="0">
            <%= x_axis_background_lines(@chart, @grid_lines, @grid_line_offsetter) %>
            <svg id={svg_id(@chart, "results")} class="columns__results" width="100%" height="100%" viewBox="0 0 100 100" preserveAspectRatio="none">
              <g>
                <%= for %Column{label: label, column_width: column_width, column_offset: column_offset, column_height: column_height, fill_color: fill_color} <- @columns do %>
                  <path id={label}
                    class="column"
                    d={"
                      M#{column_offset},100
                      v-#{column_height}
                      q0,-2 2,-2
                      h#{column_width / 2}
                      q2,0 2,2
                      v#{column_height},
                      z
                    "}
                    fill={color_to_fill(@chart.colors(), fill_color)}
                    style="transition: all 1s ease;">
                      <animate attributeName="width" values="0%;30%" dur="1s" repeatCount="freeze" />
                  </path>
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

  defp x_axis_labels(chart, columns) do
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
end
