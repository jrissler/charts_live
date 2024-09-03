defmodule ChartsLive.Live.DonutLive.ChartComponentTest do
  @moduledoc false

  import Phoenix.LiveViewTest
  use ExUnit.Case

  alias Charts.BaseChart
  alias Charts.BaseDatum
  alias Charts.DonutChart.Dataset
  alias Charts.Gradient
  alias ChartsLive.Live.DonutLive.ChartComponent

  @endpoint Endpoint

  @data [
    %BaseDatum{
      name: "slice 1",
      values: [10]
    },
    %BaseDatum{
      name: "slice 2",
      values: [20]
    },
    %BaseDatum{
      name: "slice 3",
      values: [30]
    },
    %BaseDatum{
      name: "slice 4",
      values: [40]
    },
    %BaseDatum{
      name: "slice 5",
      values: [50]
    }
  ]
  @chart %BaseChart{
    title: "A Nice Title",
    colors: %{
      gray: "#ececec",
      light_blue_gradient: %Gradient{
        start_color: "#008fb1",
        end_color: "#00d9e9"
      },
      blue_gradient: %Gradient{
        start_color: "#0052a7",
        end_color: "#005290"
      }
    },
    dataset: %Dataset{data: @data}
  }

  test "renders chart component" do
    rendered_component = render_component(ChartComponent, %{chart: @chart})

    assert rendered_component =~ ~s(class="lc-live-donut-component")
    assert rendered_component =~ ~s(50\)</title>)
  end
end
