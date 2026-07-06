defmodule ChartsLive.Live.BubbleMatrixLive.ChartComponentTest do
  @moduledoc false

  import Phoenix.LiveViewTest

  use ExUnit.Case

  alias Charts.BaseChart
  alias Charts.BubbleMatrixChart.{Dataset, Datum}
  alias Charts.Gradient
  alias ChartsLive.Live.BubbleMatrixLive.ChartComponent

  @endpoint Endpoint

  test "renders bubble matrix chart component" do
    chart = %BaseChart{
      title: "Procedure by Patient Type",
      colors: %{
        type_one: "#4096EE",
        type_two: "#FF7400",
        type_three: "#CC0000"
      },
      dataset: %Dataset{
        x_categories: ["Procedure One", "Procedure Two", "Procedure Three"],
        y_categories: ["Type 1", "Type 2", "Type 3"],
        data: [
          %Datum{
            name: "Procedure One / Type 1",
            x: "Procedure One",
            y: "Type 1",
            value: 25,
            fill_color: :type_one,
            metadata: %{percentage: 25.0}
          },
          %Datum{
            name: "Procedure Two / Type 2",
            x: "Procedure Two",
            y: "Type 2",
            value: 50,
            fill_color: :type_two,
            metadata: %{percentage: 50.0}
          },
          %Datum{
            name: "Procedure Three / Type 3",
            x: "Procedure Three",
            y: "Type 3",
            value: 100,
            fill_color: :type_three,
            metadata: %{percentage: 100.0}
          }
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert rendered_component =~ ~s(class="lc-live-bubble-matrix-component")
    assert rendered_component =~ ~s(class="bubble-matrix__chart")
    assert rendered_component =~ ~s(class="bubble-matrix__bubble")
    assert rendered_component =~ "Procedure by Patient Type"
    assert rendered_component =~ "Procedure One"
    assert rendered_component =~ "Procedure Two"
    assert rendered_component =~ "Procedure Three"
    assert rendered_component =~ "Type 1"
    assert rendered_component =~ "Type 2"
    assert rendered_component =~ "Type 3"
    assert rendered_component =~ "Procedure One / Type 1: 25"
    assert rendered_component =~ ~s(data-x-category="Procedure One")
    assert rendered_component =~ ~s(data-y-category="Type 1")
    assert rendered_component =~ ~s(data-value="25")
    assert rendered_component =~ ~s(fill="#4096EE")
  end

  test "renders one bubble for each datum" do
    chart = %BaseChart{
      title: "Bubble Count",
      colors: %{blue: "#4096EE"},
      dataset: %Dataset{
        x_categories: ["A", "B"],
        y_categories: ["One", "Two"],
        data: [
          %Datum{name: "A / One", x: "A", y: "One", value: 10, fill_color: :blue},
          %Datum{name: "A / Two", x: "A", y: "Two", value: 20, fill_color: :blue},
          %Datum{name: "B / One", x: "B", y: "One", value: 30, fill_color: :blue},
          %Datum{name: "B / Two", x: "B", y: "Two", value: 40, fill_color: :blue}
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert length(Regex.scan(~r/class="bubble-matrix__bubble"/, rendered_component)) == 4
  end

  test "renders an empty categorical matrix without bubbles" do
    chart = %BaseChart{
      title: "Empty Matrix",
      colors: %{},
      dataset: %Dataset{
        x_categories: ["A", "B"],
        y_categories: ["One", "Two"],
        data: []
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert rendered_component =~ ~s(class="lc-live-bubble-matrix-component")
    assert rendered_component =~ "Empty Matrix"
    assert rendered_component =~ "A"
    assert rendered_component =~ "B"
    assert rendered_component =~ "One"
    assert rendered_component =~ "Two"
    refute rendered_component =~ ~s(class="bubble-matrix__bubble")
  end

  test "renders gradient bubble fills" do
    chart = %BaseChart{
      title: "Gradient Matrix",
      colors: %{
        gradient: %Gradient{
          start_color: "#4096EE",
          end_color: "#CC0000"
        }
      },
      dataset: %Dataset{
        x_categories: ["A"],
        y_categories: ["One"],
        data: [
          %Datum{
            name: "A / One",
            x: "A",
            y: "One",
            value: 100,
            fill_color: :gradient
          }
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert rendered_component =~ ~s|fill="url(#gradient)"|
    assert rendered_component =~ ~s|<linearGradient id="gradient">|
    assert rendered_component =~ ~s|stop-color="#4096EE"|
    assert rendered_component =~ ~s|stop-color="#CC0000"|
  end

  test "uses the categories and value as the tooltip when a datum has no name" do
    chart = %BaseChart{
      title: "Unnamed Bubble",
      colors: %{blue: "#4096EE"},
      dataset: %Dataset{
        x_categories: ["A"],
        y_categories: ["One"],
        data: [
          %Datum{
            x: "A",
            y: "One",
            value: 10,
            fill_color: :blue
          }
        ]
      }
    }

    rendered_component = render_component(ChartComponent, %{chart: chart})

    assert rendered_component =~ "A / One: 10"
  end
end
