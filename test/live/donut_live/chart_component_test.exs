defmodule ChartsLive.Live.DonutLive.ChartComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias Charts.BaseChart
  alias Charts.BaseDatum
  alias Charts.DonutChart.Dataset
  alias Charts.Gradient
  alias ChartsLive.Live.DonutLive.ChartComponent

  @endpoint Endpoint

  setup do
    data =
      [
        %BaseDatum{
          name: "datum 1",
          values: [10]
        },
        %BaseDatum{
          name: "datum 2",
          values: [20]
        },
        %BaseDatum{
          name: "datum 3",
          values: [30]
        },
        %BaseDatum{
          name: "datum 4",
          values: [40]
        },
        %BaseDatum{
          name: "datum 5",
          values: [50]
        }
      ]

    chart = %BaseChart{
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
      dataset: %Dataset{data: data}
    }

    {:ok, chart: chart, data: data}
  end

  test "renders donut chart with data", %{chart: chart, data: data} do
    html = render_component(ChartComponent, chart: chart)

    # Check if the donut chart container is rendered
    assert html =~ "class=\"lc-live-donut-component\""
    assert html =~ "class=\"donut\""

    # Check if each datum is rendered in the donut chart
    Enum.each(data, fn datum ->
      assert html =~ "<title>#{datum.name}"
    end)
  end

  test "calculates the total correctly", %{chart: chart} do
    html = render_component(ChartComponent, chart: chart)

    # Test if the total value of the donut chart is displayed
    total = Enum.sum(Enum.map(chart.dataset.data, &hd(&1.values)))
    assert html =~ "#{total}"
  end

  test "renders chart labels and colors", %{chart: chart, data: data} do
    html = render_component(ChartComponent, chart: chart)

    # Check if chart title is rendered
    assert html =~ chart.title

    # Check if the colors of the data are correct
    Enum.each(data, fn datum ->
      assert html =~ "background-color: #{Map.get(chart.colors, datum.fill_color)}"
    end)
  end

  test "renders figure key with legend", %{chart: chart, data: data} do
    html = render_component(ChartComponent, chart: chart)

    # Check if the legend (figure key) is rendered
    Enum.each(data, fn datum ->
      assert html =~ datum.name
      assert html =~ "background-color: #{Map.get(chart.colors, datum.fill_color)}"
    end)
  end
end
