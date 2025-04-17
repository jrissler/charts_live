defmodule ChartsLive.Live.StackedBarLive.ChartComponent do
  @moduledoc """
  Stacked Bar Chart Component
  """

  use Phoenix.LiveComponent

  import ChartsLive.ChartHelpers

  alias Charts.StackedBarChart
  alias Charts.StackedColumnChart.Rectangle

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
      <.legend rectangles={@rectangles} colors={@chart.colors}/>
      <figure>
        <svg class="chart--hor-bar" role="group" width="100%" height={viewbox_height(@rows)} style="overflow: visible;">
          <svg id={svg_id(@chart, "ylabels")} class="bar__y-labels" width="14%" height="92%" y="0" x="0">
            <%= for %Charts.StackedBarChart.MultiBar{label: label, height: height, offset: offset} <- Charts.StackedBarChart.rows(@chart) do %>
              <svg x="0" y={"#{offset}%"} height={"#{height}%"} width="100%">
                  <svg width="100%" height="100%">
                  <text x="50%" y="50%" font-size="10px" alignment-baseline="middle" text-anchor="middle"><%= label %></text>
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
          <.color_defs chart={@chart} />
        </svg>
      </figure>
    </div>
    """
  end

  defp viewbox_height(rows) do
    length(rows) * 16 + 220
  end

  def x_axis_labels(assigns) do
    ~H"""
    <svg id={svg_id(@chart, "xlabels")} class="lines__x-labels" width="84%" height="8%" y="93%" x="5%" style="overflow: visible;" offset="0">
      <%= for grid_line <- @grid_lines do %>
        <svg x={"#{@offsetter.(grid_line)}%"} y="0%" height="100%" width="20%" style="overflow: visible;">
        <svg width="100%" height="100%" x="0" y="0">
          <text x="50%" y="50%" alignment_baseline="middle" text_anchor="start">
            <%= "#{axis_label(@chart).label}#{formatted_grid_line(grid_line, @label_format)}#{axis_label(@chart).appended_label}" %>
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
      <%= for color_label <- @rectangles |> Enum.map(& &1.fill_color) |> Enum.uniq() |> Enum.reverse() do %>
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
