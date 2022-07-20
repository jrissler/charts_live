defmodule ChartsLive.Live.ProgressLive.ChartComponent do
  @moduledoc """
  Progress Component
  """

  use Phoenix.LiveComponent

  alias Charts.ProgressChart
  alias ChartsLive.ProgressView

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:chart, assigns.chart)
      |> assign(:data, ProgressChart.data(assigns.chart))
      |> assign(:progress, ProgressChart.progress(assigns.chart))

    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(ProgressView, "chart_component.html", assigns)
  end
end
