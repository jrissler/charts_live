defmodule ChartsLive.Live.LollipopLive.ChartComponentTest do
  @moduledoc false

  import Phoenix.LiveViewTest

  use ExUnit.Case

  alias Charts.Axes.{BaseAxes, MagnitudeAxis}
  alias Charts.BaseChart
  alias Charts.Gradient
  alias Charts.LollipopChart.{Dataset, Datum}
  alias ChartsLive.Live.LollipopLive.ChartComponent

  @endpoint Endpoint

  test "renders chart component" do
    chart = %BaseChart{
      title: "Condition Frequency",
      colors: %{type_two: "#f1c40f"},
      dataset: %Dataset{
        axes: %BaseAxes{
          magnitude_axis: %MagnitudeAxis{
            min: 0,
            max: 100,
            appended_label: "%"
          }
        },
        data: [
          %Datum{
            name: "Diabetes",
            value: 31.4,
            fill_color: :type_two,
            metadata: %{count: 157, total: 500}
          },
          %Datum{
            name: "Sleep Apnea",
            value: 26.8,
            fill_color: :type_two,
            metadata: %{count: 134, total: 500}
          }
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert rendered_component =~ ~s(class="lc-live-lollipop-component")
    assert rendered_component =~ ~s(class="chart--hor-lollipop")
    assert rendered_component =~ "Condition Frequency"
    assert rendered_component =~ "Diabetes"
    assert rendered_component =~ "Sleep Apnea"
    assert rendered_component =~ "Diabetes: 31.4%"
    assert rendered_component =~ ~s(data-value="31.4")
    assert rendered_component =~ ~s(fill="#f1c40f")
  end

  test "renders one stem and dot for each datum" do
    chart = %BaseChart{
      title: "Lollipop Count",
      colors: %{blue: "#4096EE"},
      dataset: %Dataset{
        axes: %BaseAxes{
          magnitude_axis: %MagnitudeAxis{
            min: 0,
            max: 100
          }
        },
        data: [
          %Datum{name: "One", value: 20, fill_color: :blue},
          %Datum{name: "Two", value: 50, fill_color: :blue},
          %Datum{name: "Three", value: 80, fill_color: :blue}
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert length(Regex.scan(~r/class="lollipop__stem"/, rendered_component)) == 3
    assert length(Regex.scan(~r/class="lollipop__dot"/, rendered_component)) == 3
    assert length(Regex.scan(~r/class="lollipop__value"/, rendered_component)) == 3
  end

  test "renders an empty chart" do
    chart = %BaseChart{
      title: "Empty Lollipop Chart",
      colors: %{},
      dataset: %Dataset{
        axes: %BaseAxes{
          magnitude_axis: %MagnitudeAxis{
            min: 0,
            max: 100
          }
        },
        data: []
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert rendered_component =~ ~s(class="lc-live-lollipop-component")
    assert rendered_component =~ "Empty Lollipop Chart"
    refute rendered_component =~ ~s(class="lollipop__stem")
    refute rendered_component =~ ~s(class="lollipop__dot")
  end

  test "renders appended magnitude-axis labels" do
    chart = %BaseChart{
      title: "Percentage Chart",
      colors: %{blue: "#4096EE"},
      dataset: %Dataset{
        axes: %BaseAxes{
          magnitude_axis: %MagnitudeAxis{
            min: 0,
            max: 100,
            appended_label: "%"
          }
        },
        data: [
          %Datum{name: "Condition", value: 50, fill_color: :blue}
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert rendered_component =~ "Condition: 50%"
    assert rendered_component =~ "50%\n          </text>"
    assert rendered_component =~ "100%\n          </text>"
  end

  test "renders abbreviated values" do
    chart = %BaseChart{
      title: "Abbreviated Chart",
      colors: %{blue: "#4096EE"},
      dataset: %Dataset{
        axes: %BaseAxes{
          magnitude_axis: %MagnitudeAxis{
            min: 0,
            max: 5_000,
            label: "$",
            format: :abbreviated
          }
        },
        data: [
          %Datum{name: "Condition", value: 2_500, fill_color: :blue}
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert rendered_component =~ "Condition: $2.5k"
  end

  test "renders gradient fills" do
    chart = %BaseChart{
      title: "Gradient Chart",
      colors: %{
        gradient: %Gradient{
          start_color: "#4096EE",
          end_color: "#CC0000"
        }
      },
      dataset: %Dataset{
        axes: %BaseAxes{
          magnitude_axis: %MagnitudeAxis{
            min: 0,
            max: 100
          }
        },
        data: [
          %Datum{name: "Condition", value: 50, fill_color: :gradient}
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert rendered_component =~ ~s|fill="url(#gradient)"|
    assert rendered_component =~ ~s|stroke="url(#gradient)"|
    assert rendered_component =~ ~s|<linearGradient id="gradient">|
    assert rendered_component =~ ~s|stop-color="#4096EE"|
    assert rendered_component =~ ~s|stop-color="#CC0000"|
  end

  test "preserves metadata without interpreting it" do
    chart = %BaseChart{
      title: "Metadata Chart",
      colors: %{blue: "#4096EE"},
      dataset: %Dataset{
        axes: %BaseAxes{
          magnitude_axis: %MagnitudeAxis{
            min: 0,
            max: 100
          }
        },
        data: [
          %Datum{
            name: "Condition",
            value: 50,
            fill_color: :blue,
            metadata: %{count: 25, total: 50}
          }
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert rendered_component =~ "data-metadata"
    assert rendered_component =~ "count"
    assert rendered_component =~ "total"
  end
end
