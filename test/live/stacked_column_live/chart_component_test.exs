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

  test "renders chart component" do
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
            min: 0
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
    assert rendered_component =~ ~s(class="lc-live-stacked-column-component")
    assert rendered_component =~ ~s(2010\n          </text>)
  end

  test "renders chart component with abbreviated hover text" do
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
            max: 60_000,
            min: 0,
            label: "$",
            format: :abbreviated
          }
        },
        data: [
          %BaseDatum{
            name: "2010",
            values: %{
              blueberry: 10_000,
              orange: 5_000
            }
          },
          %BaseDatum{
            name: "2011",
            values: %{
              blueberry: 50_000,
              orange: 40_000
            }
          }
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: base_chart})

    # assert rendered_component =~ title
    assert rendered_component =~ ~s(class="lc-live-stacked-column-component")
    assert rendered_component =~ ~s(2010\n          </text>)
    assert rendered_component =~ ~s($50,000</title>)
  end

  def grid_line_fun({min, max}, _step) do
    Enum.take_every(min..max, 500)
  end
end
