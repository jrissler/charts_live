defmodule ChartsLive.ChartHelpers do
  @moduledoc """
  Helper functions for rendering SVG charts.
  """

  use Phoenix.LiveComponent

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

    base <> "-" <> suffix <> "#{:rand.uniform(1_000)}"
  end

  @doc """
  Generates SVG linearGradient definitions
  """
  def color_defs(assigns) do
    ~H"""
    <defs>
      <%= for {name, %Charts.Gradient{start_color: start_color, end_color: end_color}} <- Chart.gradient_colors(@chart) do %>
        <linearGradient id={name}>
          <stop stop-color={start_color} offset="0%" />
          <stop stop-color={end_color} offset="100%" />
        </linearGradient>
      <% end %>
    </defs>
    """
  end

  @doc """
  The function used to generate Y Axis labels
  """
  def y_axis_labels(assigns) do
    ~H"""
    <svg
      id={svg_id(@chart, "ylabels")}
      class="columns__y-labels"
      width="8%"
      height="90%"
      y="0"
      x="0"
      style="overflow: visible"
    >
      <%= for line <- @grid_lines do %>
        <svg x="0" y={"#{@offsetter.(line)}%"} height="20px" width="100%">
          <svg width="100%" height="100%">
            <text
              x="50%"
              y="50%"
              font-size="14px"
              alignment-baseline="middle"
              text-anchor="middle"
            >
              <%= axis_label(@chart).label %><%= formatted_grid_line(line, @format) %><%= axis_label(@chart).appended_label %>
            </text>
          </svg>
        </svg>
      <% end %>
    </svg>
    """
  end

  @doc """
  The function used to generate X Axis background lines
  """
  def x_axis_background_lines(assigns) do
    ~H"""
    <g id={svg_id(@chart, "lines")} class="row__lines">
      <line x1="0%" y1="0%" x2="0%" y2="100%" stroke="#efefef" stroke-width="1px" stroke-linecap="round" />
      <line x1="0%" y1="100%" x2="100%" y2="100%" stroke="#efefef" stroke-width="1px" stroke-linecap="round" />

      <%= for line <- @grid_lines do %>
        <line x1="0%" y1={"#{@offsetter.(line)}%"} x2="100%" y2={"#{@offsetter.(line)}%"} stroke="#efefef" stroke-width="1px" stroke-linecap="round" />
      <% end %>

      <line x1="0%" y1="0%" x2="100%" y2="0%" stroke="#efefef" stroke-width="1px" stroke-linecap="round" />
      <line x1="100%" y1="0%" x2="100%" y2="100%" stroke="#efefef" stroke-width="1px" stroke-linecap="round" />
    </g>
    """
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
  The function used to generate formatted values for a chart's hover values
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
            magnitude_axis: %Charts.Axes.MagnitudeAxis{
              label: label,
              appended_label: appended_label
            }
          }
        }
      }),
      do: %{label: label, appended_label: appended_label}

  def axis_label(%Charts.BaseChart{
        dataset: %Charts.ColumnChart.Dataset{
          axes: %Charts.Axes.BaseAxes{
            magnitude_axis: %Charts.Axes.MagnitudeAxis{
              label: label,
              appended_label: appended_label
            }
          }
        }
      }),
      do: %{label: label, appended_label: appended_label}

  def axis_label(%Charts.BaseChart{
        dataset: %Charts.ColumnChart.Dataset{
          axes: %Charts.Axes.XYAxes{
            y: %Charts.Axes.MagnitudeAxis{
              label: label,
              appended_label: appended_label
            }
          }
        }
      }),
      do: %{label: label, appended_label: appended_label}

  def axis_label(_), do: %{label: nil, appended_label: nil}

  defp to_abbreviated_string(value, divisor, append_value) do
    value
    |> Kernel./(divisor)
    |> Float.round(1)
    |> Float.to_string()
    |> Kernel.<>(append_value)
  end
end
