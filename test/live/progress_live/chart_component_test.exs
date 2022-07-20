defmodule ChartsLive.Live.ProgressLive.ChartComponentTest do
  import Phoenix.LiveViewTest

  use ExUnit.Case

  alias Charts.BaseChart
  alias Charts.ProgressChart
  alias Charts.ProgressChart.Dataset
  alias ChartsLive.Live.ProgressLive.ChartComponent

  @endpoint NotAThingYet
  @chart %BaseChart{
    title: "my progress chart",
    colors: %{gray: "#e2e2e2"},
    dataset: %Dataset{
      background_stroke_color: :gray,
      label: "Unchartedness",
      to_value: 100,
      current_value: 45,
      percentage_text_fill_color: :red_gradient,
      percentage_fill_color: :rosy_gradient,
      label_fill_color: :rosy_gradient
    }
  }

  describe "LiveProgress component" do
    test "render/1 mounts successfully" do
      assert render_component(ChartComponent, chart: @chart) =~
               ~s(data-testid="lc-live-progress-component")
    end

    test "renders title for accessibility" do
      assert render_component(ChartComponent, chart: @chart) =~ @chart.title
    end

    test "it renders the percentage" do
      assert render_component(ChartComponent, chart: @chart) =~
               "#{ProgressChart.progress(@chart)}"
    end
  end
end
