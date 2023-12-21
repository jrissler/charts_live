defmodule ChartsLive.ChartBehavior do
  @moduledoc """
  Behaviour for rendering SVG charts.
  """

  alias Charts.BaseChart

  @callback color_to_fill(map(), String.t()) :: String.t()
  @callback svg_id(%BaseChart{}, String.t()) :: String.t()
  @callback color_defs(%BaseChart{}) :: String.t()
  @callback y_axis_labels(%BaseChart{}, list(), function()) :: String.t()
  @callback y_axis_background_lines(%BaseChart{}, list(), function()) :: String.t()
  @callback formatted_grid_line(Integer.t(), Atom.t() | nil) :: String.t()
  @callback axis_label(%BaseChart{}) :: String.t()
  @callback formatted_hover_text(Integer.t(), Atom.t(), String.t()) :: String.t()

  @optional_callbacks color_to_fill: 2,
                      svg_id: 2,
                      color_defs: 1,
                      y_axis_labels: 3,
                      y_axis_background_lines: 3,
                      formatted_grid_line: 2,
                      axis_label: 1,
                      formatted_hover_text: 3

  defmacro __using__(_) do
    quote do
      @behaviour ChartsLive.ChartBehavior

      use Phoenix.View,
        root: "lib/charts_live/templates",
        namespace: ChartsLive

      use Phoenix.HTML

      alias Charts.Chart
      alias Charts.Gradient

      @doc """
      Returns color to fill from Gradient (matches svg def) or static color
      """
      def color_to_fill(colors, name) do
        case Map.get(colors, name) do
          %Gradient{} -> "url(##{Atom.to_string(name)})"
          value -> value
        end
      end

      @doc """
      Returns an id based on chart title and suffix
      """
      def svg_id(chart, suffix) do
        base =
          chart
          |> Chart.title()
          |> String.downcase()
          |> String.replace(~r(\s+), "-")

        base <> "-" <> suffix
      end

      @doc """
      Generates SVG linearGradient definitions
      """
      def color_defs(chart) do
        content = Enum.map(Chart.gradient_colors(chart), &linear_gradient(&1))
        content_tag(:defs, content)
      end

      @doc """
      The function used to generate Y Axis labels
      """
      def y_axis_labels(chart, grid_lines, offsetter, format \\ nil) do
        y_axis_label = axis_label(chart)
        content = Enum.map(grid_lines, &y_axis_rows(&1, offsetter, y_axis_label, format))

        content_tag(:svg, content,
          id: svg_id(chart, "ylabels"),
          class: "columns__y-labels",
          width: "8%",
          height: "90%",
          y: "0",
          x: "0",
          style: "overflow: visible"
        )
      end

      @doc """
      The function used to generate X Axis background lines
      """
      def x_axis_background_lines(chart, grid_lines, offsetter) do
        dynamic_lines = Enum.map(grid_lines, &x_axis_background_line(&1, offsetter))

        content_tag(:g, id: svg_id(chart, "lines"), class: "row__lines") do
          [
            background_line("0%", "0%", "0%", "100%"),
            background_line("0%", "100%", "100%", "100%"),
            dynamic_lines,
            background_line("0%", "0%", "100%", "0%"),
            background_line("100%", "0%", "100%", "100%")
          ]
        end
      end

      @doc """
      The function used to generate formatted values for integers
      """
      def formatted_grid_line(grid_line_value, nil), do: grid_line_value

      def formatted_grid_line(grid_line_value, :abbreviated) do
        cond do
          grid_line_value >= 1_000_000 ->
            to_abbreviated_string(grid_line_value, 1_000_000, "m")

          grid_line_value >= 999 ->
            to_abbreviated_string(grid_line_value, 1_000, "k")

          true ->
            grid_line_value
        end
      end

      @doc """
      The function used to generate formatted values for a charts hover values
      """
      def formatted_hover_text(value, nil, _value_label), do: value

      def formatted_hover_text(value, :abbreviated, value_label),
        do: value_label <> Number.Delimit.number_to_delimited(value, precision: 0)

      @doc """
      The function used to pull label from a given chart
      """
      def axis_label(%Charts.BaseChart{
            dataset: %Charts.BarChart.Dataset{
              axes: %Charts.Axes.BaseAxes{
                magnitude_axis: %Charts.Axes.MagnitudeAxis{label: label}
              }
            }
          }),
          do: label

      def axis_label(%Charts.BaseChart{
            dataset: %Charts.ColumnChart.Dataset{
              axes: %Charts.Axes.BaseAxes{
                magnitude_axis: %Charts.Axes.MagnitudeAxis{label: label}
              }
            }
          }),
          do: label

      def axis_label(%Charts.BaseChart{
            dataset: %Charts.ColumnChart.Dataset{
              axes: %Charts.Axes.XYAxes{
                y: %Charts.Axes.MagnitudeAxis{
                  label: label
                }
              }
            }
          }),
          do: label

      def axis_label(%Charts.BaseChart{
            dataset: %Charts.ColumnChart.Dataset{
              axes: %Charts.Axes.XYAxes{
                y: %Charts.Axes.MagnitudeAxis{
                  label: label
                }
              }
            }
          }),
          do: label

      def axis_label(_), do: nil

      defp x_axis_background_line(line, offsetter) do
        offset = "#{offsetter.(line)}%"

        background_line("0%", offset, "100%", offset)
      end

      defp background_line(x1, y1, x2, y2, stroke \\ 1) do
        content_tag(:line, "",
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          stroke: "#efefef",
          stroke_width: "#{stroke}px",
          stroke_linecap: "round"
        )
      end

      # , do_flush: 1
      # defoverridable init: 1

      defp y_axis_rows(grid_line, offsetter, y_axis_label, format) do
        content_tag(:svg, x: "0", y: "#{offsetter.(grid_line)}%", height: "20px", width: "100%") do
          content_tag(:svg, width: "100%", height: "100%") do
            content_tag(:text, "#{y_axis_label}#{formatted_grid_line(grid_line, format)}",
              x: "50%",
              y: "50%",
              font_size: "14px",
              alignment_baseline: "middle",
              text_anchor: "middle"
            )
          end
        end
      end

      defp to_abbreviated_string(value, divisor, append_value \\ "") do
        value
        |> Kernel./(divisor)
        |> Float.round(1)
        |> Float.to_string()
        |> Kernel.<>(append_value)
      end

      defp linear_gradient(
             {name, %Charts.Gradient{start_color: start_color, end_color: end_color}}
           ) do
        content_tag(:linearGradient, id: name) do
          [
            content_tag(:stop, "", stop_color: start_color, offset: "0%"),
            content_tag(:stop, "", stop_color: end_color, offset: "100%")
          ]
        end
      end
    end
  end
end
