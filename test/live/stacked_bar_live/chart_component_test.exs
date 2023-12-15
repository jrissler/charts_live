defmodule ChartsLive.Live.StackedBarLive.ChartComponentTest do
  @moduledoc false

  import Phoenix.LiveViewTest
  use ExUnit.Case

  alias Charts.Axes.BaseAxes
  alias Charts.Axes.MagnitudeAxis
  alias Charts.BarChart.Dataset
  alias Charts.BaseChart
  alias Charts.BaseDatum
  alias ChartsLive.Live.StackedBarLive.ChartComponent

  @endpoint Endpoint

  test "renders chart component" do
    base_chart = %BaseChart{
      title: "random title",
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

    assert rendered_component =~ ~s(class="lc-live-stacked-bar-component")
    assert rendered_component =~ ~s(50</title>)
  end

  test "renders chart component with abbreviated hover text" do
    base_chart = %BaseChart{
      title: "random title",
      colors: %{
        blueberry: "#4096EE",
        orange: "#FF7400"
      },
      dataset: %Dataset{
        axes: %BaseAxes{
          magnitude_axis: %MagnitudeAxis{
            max: 75,
            min: 0,
            label: "$",
            format: :abbreviated
          }
        },
        data: [
          %BaseDatum{
            name: "2010",
            values: %{
              blueberry: 1_000,
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

    assert rendered_component =~ ~s(class="lc-live-stacked-bar-component")
    assert rendered_component =~ ~s($50,000</title>)
  end

  def grid_line_fun({min, max}, _step) do
    Enum.take_every(min..max, 500)
  end
end
