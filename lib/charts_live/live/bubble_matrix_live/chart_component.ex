defmodule ChartsLive.Live.BubbleMatrixLive.ChartComponent do
  @moduledoc """
  A LiveComponent for rendering a categorical bubble matrix chart.

  The horizontal and vertical axes represent ordered categorical values. Each
  bubble is positioned at the intersection of its categories, while its radius
  represents the relative magnitude of its numeric value.

  Bubble positions and relative radii are calculated by `Charts.BubbleMatrixChart`.
  This component is responsible only for translating those calculated values
  into responsive SVG coordinates.
  """

  use Phoenix.LiveComponent

  import ChartsLive.ChartHelpers

  alias Charts.BubbleMatrixChart
  alias Charts.BubbleMatrixChart.Bubble
  alias Charts.Chart

  def update(assigns, socket) do
    bubbles = BubbleMatrixChart.bubbles(assigns.chart)
    x_categories = BubbleMatrixChart.x_categories(assigns.chart)
    y_categories = BubbleMatrixChart.y_categories(assigns.chart)

    left_padding = 130
    right_padding = 30
    top_padding = 30
    bottom_padding = 80
    chart_width = max(700, length(x_categories) * 120 + left_padding + right_padding)
    chart_height = max(360, length(y_categories) * 90 + top_padding + bottom_padding)
    plot_width = chart_width - left_padding - right_padding
    plot_height = chart_height - top_padding - bottom_padding

    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:colors, assigns.chart.colors || %{})
      |> assign(:bubbles, bubbles)
      |> assign(:x_categories, category_labels(x_categories))
      |> assign(:y_categories, category_labels(y_categories))
      |> assign(:x_grid_offsets, grid_offsets(x_categories))
      |> assign(:y_grid_offsets, grid_offsets(y_categories))
      |> assign(:left_padding, left_padding)
      |> assign(:right_padding, right_padding)
      |> assign(:top_padding, top_padding)
      |> assign(:bottom_padding, bottom_padding)
      |> assign(:chart_width, chart_width)
      |> assign(:chart_height, chart_height)
      |> assign(:plot_width, plot_width)
      |> assign(:plot_height, plot_height)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="lc-live-bubble-matrix-component">
      <figure>
        <svg
          id={svg_id(@chart, "chart")}
          class="bubble-matrix__chart"
          role="img"
          width="100%"
          height="100%"
          viewBox={"0 0 #{@chart_width} #{@chart_height}"}
          preserveAspectRatio="xMidYMid meet"
          style="overflow: visible;"
        >
          <title><%= Chart.title(@chart) %></title>

          <g class="bubble-matrix__grid">
            <%= for offset <- @x_grid_offsets do %>
              <% x = @left_padding + offset * @plot_width / 100.0 %>

              <line
                x1={x}
                y1={@top_padding}
                x2={x}
                y2={@top_padding + @plot_height}
                stroke="#efefef"
                stroke-width="1"
              />
            <% end %>

            <%= for offset <- @y_grid_offsets do %>
              <% y = @top_padding + offset * @plot_height / 100.0 %>

              <line
                x1={@left_padding}
                y1={y}
                x2={@left_padding + @plot_width}
                y2={y}
                stroke="#efefef"
                stroke-width="1"
              />
            <% end %>
          </g>

          <g class="bubble-matrix__y-labels">
            <%= for category <- @y_categories do %>
              <% y = @top_padding + category.offset * @plot_height / 100.0 %>

              <text
                x={@left_padding - 12}
                y={y}
                font-size="12"
                text-anchor="end"
                alignment-baseline="middle"
              >
                <%= category.label %>
              </text>
            <% end %>
          </g>

          <g class="bubble-matrix__x-labels">
            <%= for category <- @x_categories do %>
              <% x = @left_padding + category.offset * @plot_width / 100.0 %>

              <text
                x={x}
                y={@top_padding + @plot_height + 18}
                font-size="12"
                text-anchor="end"
                alignment-baseline="middle"
                transform={"rotate(-35 #{x} #{@top_padding + @plot_height + 18})"}
              >
                <%= category.label %>
              </text>
            <% end %>
          </g>

          <g id={svg_id(@chart, "results")} class="bubble-matrix__results">
            <%= for %Bubble{} = bubble <- @bubbles do %>
              <circle
                class="bubble-matrix__bubble"
                cx={bubble_x(bubble, @left_padding, @plot_width)}
                cy={bubble_y(bubble, @top_padding, @plot_height)}
                r={bubble_radius(bubble, @plot_width, @plot_height)}
                fill={color_to_fill(@colors, bubble.fill_color)}
                fill-opacity="0.82"
                stroke={color_to_fill(@colors, bubble.fill_color)}
                stroke-width="1.5"
                data-x-category={bubble.x}
                data-y-category={bubble.y}
                data-value={bubble.value}
                data-metadata={inspect(bubble.metadata)}
              >
                <title><%= bubble_title(bubble) %></title>
              </circle>
            <% end %>
          </g>

          <.color_defs chart={@chart} />
        </svg>
      </figure>
    </div>
    """
  end

  defp category_labels([]), do: []

  defp category_labels(categories) do
    category_size = 100.0 / length(categories)

    categories
    |> Enum.with_index()
    |> Enum.map(fn {category, index} ->
      %{
        label: to_string(category),
        offset: index * category_size + category_size / 2.0
      }
    end)
  end

  defp grid_offsets([]), do: []

  defp grid_offsets(categories) do
    category_size = 100.0 / length(categories)
    Enum.map(0..length(categories), &(&1 * category_size))
  end

  defp bubble_x(%Bubble{x_offset: x_offset}, left_padding, plot_width) do
    left_padding + x_offset * plot_width / 100.0
  end

  defp bubble_y(%Bubble{y_offset: y_offset}, top_padding, plot_height) do
    top_padding + y_offset * plot_height / 100.0
  end

  defp bubble_radius(%Bubble{radius: radius}, plot_width, plot_height) do
    radius * min(plot_width, plot_height) / 100.0
  end

  defp bubble_title(%Bubble{label: nil, x: x, y: y, value: value}), do: "#{x} / #{y}: #{value}"
  defp bubble_title(%Bubble{label: label, value: value}), do: "#{label}: #{value}"
end
