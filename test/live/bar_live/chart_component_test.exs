defmodule ChartsLive.Live.BarLive.ChartComponentTest do
  @moduledoc false

  import Phoenix.LiveViewTest
  use ExUnit.Case

  alias ChartsLive.Live.BarLive.ChartComponent
  alias Charts.Axes.{MagnitudeAxis, BaseAxes}
  alias Charts.BaseChart
  alias Charts.BarChart.Dataset

  @endpoint Endpoint

  test "renders card component" do
    title = "random title"

    axes = %BaseAxes{
      magnitude_axis: %MagnitudeAxis{
        min: 0,
        max: 2500
      }
    }

    base_chart = %BaseChart{title: title, dataset: %Dataset{axes: axes, data: []}}

    rendered_component = render_component(ChartComponent, %{chart: base_chart})

    assert rendered_component =~ title
    assert rendered_component =~ ~s(class="lc-live-bar-component")
  end

  def grid_line_fun({min, max}, _step) do
    Enum.take_every(min..max, 500)
  end
end
