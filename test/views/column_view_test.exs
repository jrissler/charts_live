defmodule ChartsLive.ColumnViewTest do
  @moduledoc false

  use ExUnit.Case

  import Phoenix.HTML, only: [safe_to_string: 1]
  import ChartsLive.ColumnView

  alias Charts.{BaseChart, Gradient, ColumnChart.Column}

  describe "color_to_fill/2" do
    test "should return color value" do
      assert color_to_fill(%{red: "red"}, :red) == "red"
    end

    test "should return gradient url" do
      colors = %{
        a_gradient: %Gradient{
          start_color: "red",
          end_color: "green"
        }
      }

      assert color_to_fill(colors, :a_gradient) == "url(#a_gradient)"
    end
  end

  test "svg_id/1" do
    chart = %BaseChart{title: "a title"}

    assert svg_id(chart, "suff") == "a-title-suff"
  end

  describe "y_axis_labels/3" do
    test "should return svg" do
      chart = %BaseChart{title: "a title"}
      offsetter = fn _grid_line -> 100 * 2 end

      assert safe_to_string(y_axis_labels(chart, [10, 20, 30], offsetter)) ==
               "<svg class=\"columns__y-labels\" height=\"90%\" id=\"a-title-ylabels\" style=\"overflow: visible\" width=\"8%\" x=\"0\" y=\"0\"><svg height=\"20px\" width=\"100%\" x=\"0\" y=\"200%\"><svg height=\"100%\" width=\"100%\"><text alignment-baseline=\"middle\" font-size=\"14px\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">10</text></svg></svg><svg height=\"20px\" width=\"100%\" x=\"0\" y=\"200%\"><svg height=\"100%\" width=\"100%\"><text alignment-baseline=\"middle\" font-size=\"14px\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">20</text></svg></svg><svg height=\"20px\" width=\"100%\" x=\"0\" y=\"200%\"><svg height=\"100%\" width=\"100%\"><text alignment-baseline=\"middle\" font-size=\"14px\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">30</text></svg></svg></svg>"
    end
  end

  describe "x_axis_labels/2" do
    test "should return svg" do
      chart = %BaseChart{title: "a title"}
      columns = [%Column{label: "test"}, %Column{label: "test2"}]

      assert safe_to_string(x_axis_labels(chart, columns)) ==
               "<svg class=\"columns__x-labels\" height=\"8%\" id=\"a-title-xlabels\" width=\"90.5%\" x=\"9.5%\" y=\"92%\"><svg height=\"100%\" width=\"%\" x=\"%\" y=\"0%\"><svg height=\"100%\" width=\"100%\"><text alignment-baseline=\"middle\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">test</text></svg></svg><svg height=\"100%\" width=\"%\" x=\"%\" y=\"0%\"><svg height=\"100%\" width=\"100%\"><text alignment-baseline=\"middle\" text-anchor=\"middle\" x=\"50%\" y=\"50%\">test2</text></svg></svg></svg>"
    end
  end

  describe "color_defs/1" do
    test "should return single linearGradient definition" do
      chart = %BaseChart{
        title: "a title",
        colors: %{
          blue_gradient: %Gradient{
            start_color: "#0011FF",
            end_color: "#1100FF"
          }
        }
      }

      assert safe_to_string(color_defs(chart)) ==
               "<defs><linearGradient id=\"blue_gradient\"><stop offset=\"0%\" stop-color=\"#0011FF\"></stop><stop offset=\"100%\" stop-color=\"#1100FF\"></stop></linearGradient></defs>"
    end

    test "should return no linearGradient definitions" do
      chart = %BaseChart{
        title: "a title",
        colors: %{
          blue: "#0011FF"
        }
      }

      assert safe_to_string(color_defs(chart)) ==
               "<defs></defs>"
    end
  end
end
