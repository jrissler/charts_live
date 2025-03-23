defmodule ChartsLive.Live.ColumnLive.ChartComponentTest do
  @moduledoc false

  import Phoenix.LiveViewTest
  use ExUnit.Case

  alias Charts.Axes.BaseAxes
  alias Charts.Axes.MagnitudeAxis
  alias Charts.BaseChart
  alias Charts.ColumnChart.Dataset
  alias ChartsLive.Live.ColumnLive.ChartComponent

  @endpoint Endpoint

  test "renders card component" do
    title = "random title"

    axes = %BaseAxes{
      magnitude_axis: %MagnitudeAxis{
        min: 0,
        max: 2500,
        grid_lines: &__MODULE__.grid_line_fun/2
      }
    }

    base_chart = %BaseChart{title: title, dataset: %Dataset{axes: axes, data: []}}

    rendered_component = render_component(ChartComponent, %{chart: base_chart})

    assert rendered_component =~ title
    assert rendered_component =~ ~s(class="lc-live-column-component")
  end

  def grid_line_fun({min, max}, _step) do
    Enum.take_every(min..max, 500)
  end
end
