defmodule ChartsLive.BarViewTest do
  @moduledoc false

  use ExUnit.Case

  import ChartsLive.BarView
  import Phoenix.HTML, only: [safe_to_string: 1]

  alias Charts.Axes.BaseAxes
  alias Charts.Axes.MagnitudeAxis
  alias Charts.BarChart.Dataset
  alias Charts.BaseChart

  describe "x_axis_labels/2" do
    test "should return svg" do
      chart = %BaseChart{title: "a title"}
      grid_lines = [140, 280]
      offsetter = fn grid_line -> 100 * grid_line / 2500 end

      assert safe_to_string(x_axis_labels(chart, grid_lines, offsetter, nil)) ==
               "<svg class=\"lines__x-labels\" height=\"8%\" id=\"a-title-xlabels\" offset=\"0\" style=\"overflow: visible;\" width=\"90%\" x=\"1%\" y=\"92%\"><svg height=\"100%\" style=\"overflow: visible;\" width=\"20%\" x=\"5.6%\" y=\"0%\"><svg height=\"100%\" width=\"100%\" x=\"0\" y=\"0\"><text alignment-baseline=\"middle\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">140</text></svg></svg><svg height=\"100%\" style=\"overflow: visible;\" width=\"20%\" x=\"11.2%\" y=\"0%\"><svg height=\"100%\" width=\"100%\" x=\"0\" y=\"0\"><text alignment-baseline=\"middle\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">280</text></svg></svg></svg>"
    end

    test "should return svg with formatted values" do
      axes = %BaseAxes{
        magnitude_axis: %MagnitudeAxis{
          min: 0,
          max: 2_000_000,
          label: "$",
          format: :abbreviated,
          grid_lines: &__MODULE__.grid_line_fun/2
        }
      }

      chart = %BaseChart{title: "a title", dataset: %Dataset{axes: axes, data: []}}

      grid_lines = [1_100_000, 678_910, 7000, 10]
      offsetter = fn grid_line -> 100 * grid_line / 2_000_000 end

      assert safe_to_string(x_axis_labels(chart, grid_lines, offsetter, :abbreviated)) ==
               "<svg class=\"lines__x-labels\" height=\"8%\" id=\"a-title-xlabels\" offset=\"0\" style=\"overflow: visible;\" width=\"90%\" x=\"1%\" y=\"92%\"><svg height=\"100%\" style=\"overflow: visible;\" width=\"20%\" x=\"55.0%\" y=\"0%\"><svg height=\"100%\" width=\"100%\" x=\"0\" y=\"0\"><text alignment-baseline=\"middle\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">$1.1m</text></svg></svg><svg height=\"100%\" style=\"overflow: visible;\" width=\"20%\" x=\"33.9455%\" y=\"0%\"><svg height=\"100%\" width=\"100%\" x=\"0\" y=\"0\"><text alignment-baseline=\"middle\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">$67.9k</text></svg></svg><svg height=\"100%\" style=\"overflow: visible;\" width=\"20%\" x=\"0.35%\" y=\"0%\"><svg height=\"100%\" width=\"100%\" x=\"0\" y=\"0\"><text alignment-baseline=\"middle\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">$7.0k</text></svg></svg><svg height=\"100%\" style=\"overflow: visible;\" width=\"20%\" x=\"5.0e-4%\" y=\"0%\"><svg height=\"100%\" width=\"100%\" x=\"0\" y=\"0\"><text alignment-baseline=\"middle\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">$10</text></svg></svg></svg>"
    end
  end

  describe "x_axis_background_lines/3" do
    test "should return svg" do
      chart = %BaseChart{title: "a title"}
      grid_lines = [140, 280]
      offsetter = fn grid_line -> 100 * grid_line / 2500 end

      assert safe_to_string(x_axis_background_lines(chart, grid_lines, offsetter)) ==
               "<g class=\"row__lines\" id=\"a-title-lines\"><line stroke=\"#efefef\" stroke-linecap=\"round\" stroke-width=\"1px\" x1=\"0%\" x2=\"0%\" y1=\"0%\" y2=\"100%\"></line><line stroke=\"#efefef\" stroke-linecap=\"round\" stroke-width=\"1px\" x1=\"0%\" x2=\"100%\" y1=\"100%\" y2=\"100%\"></line><line stroke=\"#efefef\" stroke-linecap=\"round\" stroke-width=\"1px\" x1=\"0%\" x2=\"100%\" y1=\"5.6%\" y2=\"5.6%\"></line><line stroke=\"#efefef\" stroke-linecap=\"round\" stroke-width=\"1px\" x1=\"0%\" x2=\"100%\" y1=\"11.2%\" y2=\"11.2%\"></line><line stroke=\"#efefef\" stroke-linecap=\"round\" stroke-width=\"1px\" x1=\"0%\" x2=\"100%\" y1=\"0%\" y2=\"0%\"></line><line stroke=\"#efefef\" stroke-linecap=\"round\" stroke-width=\"1px\" x1=\"100%\" x2=\"100%\" y1=\"0%\" y2=\"100%\"></line></g>"
    end
  end
end
