defmodule ChartsLive.Live.StackedBarLive.ChartComponent do
  @moduledoc """
  A LiveComponent for rendering a stacked horizontal bar chart.

  This component dynamically sizes and positions the bars, axes, and labels based on the provided dataset.

  ## Layout and Padding Constants

  The following visual constants are assigned during `update/2`:

  - `:top_padding` - Pixels of empty space above the first row of bars (default: `20.0`).
  - `:bottom_padding` - Pixels of empty space below the last row of bars, usually to make room for x-axis labels (default: `30.0`).
  - `:row_height` - The full vertical height allocated for each data row, including margin space (default: `20.0`).
  - `:bar_margin` - Vertical margin inside each row between the bar and the row boundary (default: `3.0`).
  - `:bar_height` - The actual visible height of each colored bar (row height minus margins, default: `14.0`).

  These values ensure:
  - Uniform row spacing regardless of number of rows.
  - Correct padding around the top and bottom of the chart.
  - Bars stay visually centered inside their rows.
  - No gridlines or elements intrude into the x-axis label space.

  ## Behavior

  - The component calculates a dynamic `viewBox` height based on the number of rows and the padding.
  - Grid lines are drawn between the top and bottom paddings, matching the visual boundaries of the bars.
  - All SVG elements (bars, labels, axes) are positioned relative to these constants for pixel-perfect alignment.
  """

  use Phoenix.LiveComponent

  import ChartsLive.ChartHelpers

  alias Charts.StackedBarChart
  alias Charts.StackedColumnChart.Rectangle

  def update(assigns, socket) do
    x_axis = assigns.chart.dataset.axes.magnitude_axis
    grid_lines = x_axis.grid_lines.({x_axis.min, x_axis.max}, 5)

    grid_line_offsetter = fn grid_line ->
      100 * grid_line / x_axis.max
    end

    rows = StackedBarChart.rows(assigns.chart)

    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:rows, rows)
      |> assign(:rectangles, StackedBarChart.rectangles(assigns.chart))
      |> assign(:grid_lines, grid_lines)
      |> assign(:offsetter, grid_line_offsetter)
      |> assign(:x_axis_format, x_axis.format)
      |> assign(:x_axis_value_label, x_axis.label)
      |> assign(:top_padding, 20.0)
      |> assign(:bottom_padding, 30.0)
      |> assign(:row_height, 20.0)
      |> assign(:bar_margin, 3.0)
      |> assign(:bar_height, 14.0)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="lc-live-stacked-bar-component">
      <.legend rectangles={@rectangles} colors={@chart.colors} />
      <figure>
        <svg
          class="chart--hor-bar"
          role="group"
          width="100%"
          height={viewbox_height(@rows, @top_padding, @bottom_padding, @row_height)}
          style="overflow: visible;"
        >
          <svg id={svg_id(@chart, "ylabels")} class="bar__y-labels" width="14%" height="100%" y="0" x="0">
            <%= for %Charts.StackedBarChart.MultiBar{label: label, height: height, offset: offset} <- @rows do %>
              <svg x="0" y={"#{offset + @top_padding}"} height={"#{height}"} width="100%">
                <svg width="100%" height="100%">
                  <text x="50%" y="50%" font-size="10px" alignment-baseline="middle" text-anchor="middle">
                    <%= label %>
                  </text>
                </svg>
              </svg>
            <% end %>
          </svg>

          <svg width="84%" height="100%" x="14%" y="0">
            <g class="y-line">
              <!-- Left vertical baseline -->
              <line
                x1="0%"
                y1={@top_padding}
                x2="0%"
                y2={viewbox_height(@rows, @top_padding, @bottom_padding, @row_height) - @bottom_padding}
                stroke="#efefef"
                stroke-width="2px"
                stroke-linecap="round"
              />

              <!-- Bottom baseline -->
              <line
                x1="0%"
                y1={viewbox_height(@rows, @top_padding, @bottom_padding, @row_height) - @bottom_padding}
                x2="100%"
                y2={viewbox_height(@rows, @top_padding, @bottom_padding, @row_height) - @bottom_padding}
                stroke="#efefef"
                stroke-width="2px"
                stroke-linecap="round"
              />

              <!-- Vertical gridlines -->
              <%= for grid_line <- @grid_lines do %>
                <% offset = @offsetter.(grid_line) %>
                <line
                  x1={"#{offset}%"}
                  y1={@top_padding}
                  x2={"#{offset}%"}
                  y2={viewbox_height(@rows, @top_padding, @bottom_padding, @row_height) - @bottom_padding}
                  stroke="#efefef"
                  stroke-width="2px"
                  stroke-linecap="round"
                />
              <% end %>
            </g>

            <svg
              id={svg_id(@chart, "results")}
              class="columns__results"
              width="100%"
              height="100%"
              viewBox={"0 0 100 #{viewbox_height(@rows, @top_padding, @bottom_padding, @row_height)}"}
              preserveAspectRatio="none"
            >
              <g>
                <%= for %Rectangle{width: width, x_offset: x_offset, y_offset: y_offset, height: height, fill_color: fill_color, label: label} <- @rectangles do %>
                  <rect
                    x={"#{x_offset}"}
                    y={"#{y_offset + @top_padding}"}
                    height={"#{height}"}
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

          <.x_axis_labels
            chart={@chart}
            grid_lines={@grid_lines}
            offsetter={@offsetter}
            label_format={@x_axis_format}
            top_padding={@top_padding}
            bottom_padding={@bottom_padding}
            row_height={@row_height}
            rows={@rows}
          />

          <.color_defs chart={@chart} />
        </svg>
      </figure>
    </div>
    """
  end

  defp viewbox_height(rows, top_padding, bottom_padding, row_height) do
    top_padding + length(rows) * row_height + bottom_padding
  end

  def x_axis_labels(assigns) do
    axis_label = axis_label(assigns.chart)

    ~H"""
    <svg
      id={svg_id(@chart, "xlabels")}
      class="lines__x-labels"
      width="84%"
      height="30"
      y={viewbox_height(@rows, @top_padding, @bottom_padding, @row_height) - 30}
      x="5%"
      style="overflow: visible;"
    >
      <%= for grid_line <- @grid_lines do %>
        <svg x={"#{@offsetter.(grid_line)}%"} y="0" height="100%" width="20%" style="overflow: visible;">
          <svg width="100%" height="100%" x="0" y="0">
            <text x="50%" y="50%" alignment-baseline="middle" text-anchor="start">
              <%= "#{axis_label.label}#{formatted_grid_line(grid_line, @label_format)}#{axis_label.appended_label}" %>
            </text>
          </svg>
        </svg>
      <% end %>
    </svg>
    """
  end

  def legend(assigns) do
    ~H"""
    <dl style="margin-left: 10%; float: right;">
      <%= for color_label <- @rectangles |> Enum.map(& &1.fill_color) |> Enum.uniq() do %>
        <dt style={"background-color: #{@colors[color_label]}; display: inline-block; height: 10px; width: 20px; vertical-align: middle;"}></dt>
        <dd style="display: inline-block; margin: 0px 10px 0 6px; padding-bottom: 0;">
          <%= color_to_label(color_label) %>
        </dd>
      <% end %>
    </dl>
    """
  end

  defp color_to_label(atom_color) do
    atom_color
    |> Atom.to_string()
    |> String.capitalize()
  end
end
