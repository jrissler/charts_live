defmodule ChartsLive.Live.StackedColumnLive.ChartComponent do
  @moduledoc """
  A LiveComponent for rendering a stacked vertical column chart.

  Mimics the layout strategy of the horizontal StackedBarLive.ChartComponent.
  """

  use Phoenix.LiveComponent

  import ChartsLive.ChartHelpers

  alias Charts.StackedColumnChart
  alias Charts.StackedColumnChart.Rectangle

  def update(assigns, socket) do
    y_axis = assigns.chart.dataset.axes.magnitude_axis
    grid_lines = [y_axis.min | y_axis.grid_lines.({y_axis.min, y_axis.max}, 5)]

    offsetter = fn grid_line ->
      100 * (y_axis.max - grid_line) / (y_axis.max - y_axis.min)
    end

    columns = StackedColumnChart.columns(assigns.chart)
    rectangles = StackedColumnChart.rectangles(assigns.chart)

    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:columns, columns)
      |> assign(:rectangles, rectangles)
      |> assign(:grid_lines, grid_lines)
      |> assign(:offsetter, offsetter)
      |> assign(:y_axis_format, y_axis.format)
      |> assign(:y_axis_value_label, y_axis.label)
      |> assign(:left_padding, 40)
      |> assign(:right_padding, 30)
      |> assign(:top_padding, 20)
      |> assign(:bottom_padding, 30)
      |> assign(:column_width, 40)
      |> assign(:bar_margin, 3.0)
      |> assign(:bar_width, 28.0)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="lc-live-stacked-column-component">
      <.legend rectangles={@rectangles} colors={@chart.colors} />
      <figure>
        <svg
          class="chart--ver-bar"
          role="group"
          width="100%"
          height="100%"
          style="overflow: visible;"
        >
          <svg
            id={svg_id(@chart, "ylabels")}
            class="bar__y-labels"
            height="100%"
            width="100%"
          >
            <%= for grid_line <- @grid_lines do %>
              <% y = @top_padding + @offsetter.(grid_line) %>
              <text
                x={@left_padding - 6}
                y={y}
                font-size="10"
                text-anchor="end"
                alignment-baseline="middle"
              >
                <%= formatted_grid_line(grid_line, @y_axis_format) %>
              </text>
            <% end %>
          </svg>

          <svg
            width="100%"
            height="100%"
            x="0"
            y="0"
          >
            <g class="grid-lines">
              <%= for grid_line <- @grid_lines do %>
                <% y = @top_padding + @offsetter.(grid_line) %>
                <line
                  x1={@left_padding}
                  x2={"calc(100% - #{@right_padding}px)"}
                  y1={y}
                  y2={y}
                  stroke="#efefef"
                  stroke-width="1"
                />
              <% end %>
            </g>

            <svg
              id={svg_id(@chart, "results")}
              class="columns__results"
              width="100%"
              height="100%"
            >
              <g>
                <%= for %Rectangle{width: _, x_offset: x_offset, y_offset: y_offset, height: height, fill_color: fill_color, label: label} <- @rectangles do %>
                  <% x = @left_padding + trunc(x_offset * @column_width) + div(@column_width - trunc(@bar_width), 2) %>
                  <rect
                    x={x}
                    y={@top_padding + y_offset}
                    width={@bar_width}
                    height={height}
                    fill={@chart.colors[fill_color]}
                    class="stacked-column-rectangle"
                  >
                    <title><%= formatted_hover_text(label, @y_axis_format, @y_axis_value_label) %></title>
                  </rect>
                <% end %>
              </g>
            </svg>
          </svg>

          <svg
            id={svg_id(@chart, "xlabels")}
            class="lines__x-labels"
            width="100%"
            height="30"
            y={@top_padding + 100}
            x="0"
            style="overflow: visible;"
          >
            <%= for {column, index} <- Enum.with_index(@columns) do %>
              <% x = @left_padding + index * @column_width + div(@column_width, 2) %>
              <text
                x={x}
                y="10"
                font-size="10"
                text-anchor="middle"
                alignment-baseline="hanging"
              >
                <%= column.label %>
              </text>
            <% end %>
          </svg>

          <.color_defs chart={@chart} />
        </svg>
      </figure>
    </div>
    """
  end

  def legend(assigns) do
    ~H"""
    <dl style="margin-left: 10%; float: right;">
      <%= for color_label <- Enum.uniq(Enum.map(@rectangles, & &1.fill_color)) do %>
        <dt style={"background-color: #{@colors[color_label]}; display: inline-block; height: 10px; width: 20px; vertical-align: middle;"}></dt>
        <dd style="display: inline-block; margin: 0px 10px 0 6px; padding-bottom: 0;">
          <%= color_to_label(color_label) %>
        </dd>
      <% end %>
    </dl>
    """
  end

  defp color_to_label(atom_color), do: atom_color |> Atom.to_string() |> String.capitalize()
end
