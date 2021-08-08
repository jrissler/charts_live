defmodule ChartsLive.Live.LineLive.ChartComponentTest do
  @moduledoc false

  import Phoenix.LiveViewTest
  use ExUnit.Case

  alias ChartsLive.Live.LineLive.ChartComponent
  alias Charts.Axes.{MagnitudeAxis, XYAxes}
  alias Charts.BaseChart
  alias Charts.ColumnChart.Dataset

  @endpoint Endpoint

  test "renders card component" do
    title = "random title"

    axes = %XYAxes{
      x: %MagnitudeAxis{
        min: 0,
        max: 2500,
        grid_lines: &__MODULE__.grid_line_fun/2
      },
      y: %MagnitudeAxis{
        min: 0,
        max: 2500,
        grid_lines: &__MODULE__.grid_line_fun/2
      }
    }

    base_chart = %BaseChart{title: title, dataset: %Dataset{axes: axes, data: []}}

    rendered_component = render_component(ChartComponent, %{chart: base_chart})

    assert rendered_component =~ title
    assert rendered_component =~ ~s(class="lc-live-line-component")
  end

  def grid_line_fun({min, max}, _step) do
    Enum.take_every(min..max, 500)
  end
end
