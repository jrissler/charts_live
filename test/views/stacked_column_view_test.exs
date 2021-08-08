defmodule ChartsLive.StackedColumnViewTest do
  @moduledoc false

  use ExUnit.Case

  import Phoenix.HTML, only: [safe_to_string: 1]
  import ChartsLive.StackedColumnView

  alias Charts.{BaseChart, ColumnChart.Column}
  alias Charts.StackedColumnChart.Rectangle

  describe "x_axis_labels/2" do
    test "should return svg" do
      chart = %BaseChart{title: "a title"}
      columns = [%Column{label: "test"}, %Column{label: "test2"}]

      assert safe_to_string(x_axis_labels(chart, columns)) ==
               "<svg class=\"columns__x-labels\" height=\"8%\" id=\"a-title-xlabels\" width=\"90.5%\" x=\"9.5%\" y=\"92%\"><svg height=\"100%\" width=\"%\" x=\"%\" y=\"0%\"><svg height=\"100%\" width=\"100%\"><text alignment-baseline=\"middle\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">test</text></svg></svg><svg height=\"100%\" width=\"%\" x=\"%\" y=\"0%\"><svg height=\"100%\" width=\"100%\"><text alignment-baseline=\"middle\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">test2</text></svg></svg></svg>"
    end
  end

  describe "legend/2" do
    test "should return legend based on rectangles and colors" do
      rectangles = [
        %Rectangle{fill_color: :blueberry},
        %Rectangle{fill_color: :apple}
      ]

      colors = %{
        blueberry: "#4096EE",
        apple: "#CC0000",
        random: "#FF7400"
      }

      legend = safe_to_string(legend(rectangles, colors))

      assert legend ==
               "<dl style=\"margin-left: 10%; float: right;\"><dt style=\"background-color: #CC0000; display: inline-block; height: 10px; width: 20px; vertical-align: middle;\"></dt><dd style=\"display: inline-block; margin: 0px 10px 0 6px; padding-bottom: 0;\">Apple</dd><dt style=\"background-color: #4096EE; display: inline-block; height: 10px; width: 20px; vertical-align: middle;\"></dt><dd style=\"display: inline-block; margin: 0px 10px 0 6px; padding-bottom: 0;\">Blueberry</dd></dl>"

      refute legend =~ "random"
      refute legend =~ "#FF7400"
    end
  end
end
