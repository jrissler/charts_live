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

  @optional_callbacks color_to_fill: 2,
                      svg_id: 2,
                      color_defs: 1,
                      y_axis_labels: 3,
                      y_axis_background_lines: 3

  defmacro __using__(_) do
    quote do
      @behaviour ChartsLive.ChartBehavior

      use Phoenix.View,
        root: "lib/charts_live/templates",
        namespace: ChartsLive

      use Phoenix.HTML

      alias Charts.{Chart, Gradient}

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
      def y_axis_labels(chart, grid_lines, offsetter) do
        content = Enum.map(grid_lines, &y_axis_rows(&1, offsetter))

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

      defp y_axis_rows(grid_line, offsetter) do
        content_tag(:svg, x: "0", y: "#{offsetter.(grid_line)}%", height: "20px", width: "100%") do
          content_tag(:svg, width: "100%", height: "100%") do
            content_tag(:text, grid_line,
              x: "50%",
              y: "50%",
              font_size: "14px",
              alignment_baseline: "middle",
              text_anchor: "middle"
            )
          end
        end
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
