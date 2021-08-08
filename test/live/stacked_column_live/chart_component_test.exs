defmodule ChartsLive.Live.StackedColumnLive.ChartComponentTest do
  @moduledoc false

  import Phoenix.LiveViewTest
  use ExUnit.Case

  alias ChartsLive.Live.StackedColumnLive.ChartComponent
  alias Charts.Axes.{MagnitudeAxis, BaseAxes}
  alias Charts.{BaseChart, BaseDatum}
  alias Charts.ColumnChart.Dataset

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

    assert rendered_component =~ title
    assert rendered_component =~ ~s(class="lc-live-stacked-bar-component")
  end

  def grid_line_fun({min, max}, _step) do
    Enum.take_every(min..max, 500)
  end
end
