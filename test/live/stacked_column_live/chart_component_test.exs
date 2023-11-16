defmodule ChartsLive.Live.StackedColumnLive.ChartComponentTest do
  @moduledoc false

  import Phoenix.LiveViewTest
  use ExUnit.Case

  alias Charts.Axes.BaseAxes
  alias Charts.Axes.MagnitudeAxis
  alias Charts.BaseChart
  alias Charts.BaseDatum
  alias Charts.ColumnChart.Dataset
  alias ChartsLive.Live.StackedColumnLive.ChartComponent

  @endpoint Endpoint

  test "renders card component" do
    title = "random title"

    base_chart = %BaseChart{
      title: title,
      colors: %{
        blueberry: "#4096EE",
        orange: "#FF7400"
      },
      dataset: %Dataset{
        axes: %BaseAxes{
          magnitude_axis: %MagnitudeAxis{
            max: 75,
            min: 0,
            label: "$"
          }
        },
        data: [
          %BaseDatum{
            name: "2010",
            values: %{
              blueberry: 1,
              orange: 5
            }
          },
          %BaseDatum{
            name: "2011",
            values: %{
              blueberry: 50,
              orange: 40
            }
          }
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: base_chart})

    # assert rendered_component =~ title
    assert rendered_component =~ ~s(class="lc-live-stacked-bar-component")
    assert rendered_component =~ ~s(2010</text>)
  end

  def grid_line_fun({min, max}, _step) do
    Enum.take_every(min..max, 500)
  end
end
