defmodule ChartsLive.Live.StackedColumnLive.ChartComponent do
  @moduledoc """
  Stacked Bar Chart Component
  """

  use Phoenix.LiveComponent

  alias Charts.StackedColumnChart
  alias ChartsLive.StackedColumnView

  def update(assigns, socket) do
    y_axis = assigns.chart.dataset.axes.magnitude_axis
    # Hardcode the number of steps to take as 10 for now
    grid_lines = y_axis.grid_lines.({y_axis.min, y_axis.max}, 10)
    grid_line_offsetter = fn grid_line -> 100 * (y_axis.max - grid_line) / y_axis.max end

    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:columns, StackedColumnChart.columns(assigns.chart))
      |> assign(:rectangles, StackedColumnChart.rectangles(assigns.chart))
      |> assign(:grid_lines, grid_lines)
      |> assign(:grid_line_offsetter, grid_line_offsetter)
      |> assign(:y_axis_format, y_axis.format)
      |> assign(:y_axis_value_label, y_axis.label)

    {:ok, socket}
  end

  def render(assigns) do
    StackedColumnView.render("chart_component.html", assigns)
  end
end
