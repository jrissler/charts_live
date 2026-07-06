defmodule ChartsLive.Live.LollipopLive.ChartComponent do
  @moduledoc """
  A LiveComponent for rendering a horizontal lollipop chart.

  Each data point is displayed as a labeled horizontal stem ending in a dot.
  The stem length and dot position represent the data point's value relative
  to the configured magnitude axis.
  """

  use Phoenix.LiveComponent

  import ChartsLive.ChartHelpers

  alias Charts.Chart
  alias Charts.LollipopChart

  @chart_width 1_000.0
  @left_padding 220.0
  @right_padding 50.0
  @top_padding 20.0
  @bottom_padding 45.0
  @row_height 30.0
  @dot_radius 6.0

  def update(assigns, socket) do
    x_axis = assigns.chart.dataset.axes.magnitude_axis
    lollipops = LollipopChart.lollipops(assigns.chart)
    grid_lines = x_axis.grid_lines.({x_axis.min, x_axis.max}, 5)

    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:lollipops, lollipops)
      |> assign(:grid_lines, grid_lines)
      |> assign(:x_axis_min, x_axis.min)
      |> assign(:x_axis_max, x_axis.max)
      |> assign(:x_axis_format, x_axis.format)
      |> assign(:x_axis_label, x_axis.label)
      |> assign(:x_axis_appended_label, x_axis.appended_label)
      |> assign(:chart_width, @chart_width)
      |> assign(:chart_height, chart_height(lollipops))
      |> assign(:left_padding, @left_padding)
      |> assign(:right_padding, @right_padding)
      |> assign(:top_padding, @top_padding)
      |> assign(:bottom_padding, @bottom_padding)
      |> assign(:row_height, @row_height)
      |> assign(:plot_width, @chart_width - @left_padding - @right_padding)
      |> assign(:dot_radius, @dot_radius)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="lc-live-lollipop-component">
      <figure>
        <svg
          id={svg_id(@chart, "chart")}
          class="chart--hor-lollipop"
          role="group"
          width="100%"
          height={@chart_height}
          viewBox={"0 0 #{@chart_width} #{@chart_height}"}
          preserveAspectRatio="xMidYMid meet"
          style="overflow: visible;"
        >
          <title><%= Chart.title(@chart) %></title>

          <g id={svg_id(@chart, "grid")} class="lollipop__grid">
            <line
              x1={@left_padding}
              y1={@top_padding}
              x2={@left_padding}
              y2={plot_bottom(@chart_height, @bottom_padding)}
              stroke="#efefef"
              stroke-width="2"
              stroke-linecap="round"
            />

            <line
              x1={@left_padding}
              y1={plot_bottom(@chart_height, @bottom_padding)}
              x2={@left_padding + @plot_width}
              y2={plot_bottom(@chart_height, @bottom_padding)}
              stroke="#efefef"
              stroke-width="2"
              stroke-linecap="round"
            />

            <%= for grid_line <- @grid_lines do %>
              <% x = grid_line_x(grid_line, @x_axis_min, @x_axis_max, @left_padding, @plot_width) %>

              <line
                x1={x}
                y1={@top_padding}
                x2={x}
                y2={plot_bottom(@chart_height, @bottom_padding)}
                stroke="#efefef"
                stroke-width="1"
                stroke-linecap="round"
              />
            <% end %>
          </g>

          <g id={svg_id(@chart, "results")} class="lollipop__results">
            <%= for {lollipop, index} <- Enum.with_index(@lollipops) do %>
              <% y = row_center(index, @top_padding, @row_height) %>
              <% dot_x = value_x(lollipop.dot_offset, @left_padding, @plot_width) %>
              <% fill = color_to_fill(Chart.colors(@chart), lollipop.fill_color) %>

              <text
                class="lollipop__label"
                x={@left_padding - 12}
                y={y}
                font-size="12px"
                alignment-baseline="middle"
                text-anchor="end"
              >
                <%= lollipop.label %>
              </text>

              <line
                class="lollipop__stem"
                x1={@left_padding}
                y1={y}
                x2={dot_x}
                y2={y}
                stroke={fill}
                stroke-width="3"
                stroke-linecap="round"
                data-value={lollipop.value}
              />

              <circle
                class="lollipop__dot"
                cx={dot_x}
                cy={y}
                r={@dot_radius}
                fill={fill}
                stroke={fill}
                stroke-width="2"
                data-value={lollipop.value}
                data-metadata={inspect(lollipop.metadata)}
              >
                <title><%= "#{lollipop.label}: #{formatted_value(lollipop.value, @x_axis_format, @x_axis_label, @x_axis_appended_label)}" %></title>
              </circle>

              <text
                class="lollipop__value"
                x={dot_x + 12}
                y={y}
                font-size="11px"
                alignment-baseline="middle"
                text-anchor="start"
              >
                <%= formatted_value(lollipop.value, @x_axis_format, @x_axis_label, @x_axis_appended_label) %>
              </text>
            <% end %>
          </g>

          <g id={svg_id(@chart, "xlabels")} class="lollipop__x-labels">
            <%= for grid_line <- @grid_lines do %>
              <% x = grid_line_x(grid_line, @x_axis_min, @x_axis_max, @left_padding, @plot_width) %>

              <text
                x={x}
                y={@chart_height - 15}
                font-size="11px"
                alignment-baseline="middle"
                text-anchor="middle"
              >
                <%= formatted_value(grid_line, @x_axis_format, @x_axis_label, @x_axis_appended_label) %>
              </text>
            <% end %>
          </g>

          <.color_defs chart={@chart} />
        </svg>
      </figure>
    </div>
    """
  end

  defp chart_height(lollipops), do: @top_padding + length(lollipops) * @row_height + @bottom_padding

  defp plot_bottom(chart_height, bottom_padding), do: chart_height - bottom_padding

  defp row_center(index, top_padding, row_height), do: top_padding + index * row_height + row_height / 2.0

  defp value_x(offset, left_padding, plot_width), do: left_padding + offset / 100.0 * plot_width

  defp grid_line_x(_grid_line, min, max, left_padding, _plot_width) when min == max, do: left_padding

  defp grid_line_x(grid_line, min, max, left_padding, plot_width) do
    left_padding + (grid_line - min) / (max - min) * plot_width
  end

  defp formatted_value(value, nil, label, appended_label), do: "#{label}#{value}#{appended_label}"

  defp formatted_value(value, format, label, appended_label) do
    "#{label}#{formatted_grid_line(value, format)}#{appended_label}"
  end
end
