defmodule GenReport do
  alias GenReport.Parser

  def build() do
    {:error, "Insira o nome de um arquivo"}
  end

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(
      {:ok, %{"all_hours" => %{}, "hours_per_month" => %{}, "hours_per_year" => %{}}},
      fn line, report -> report_construct(line, report) end
    )
  end

  defp report_construct(
         [name, hours, _day, month, year],
         {:ok,
          %{
            "all_hours" => all_hours,
            "hours_per_month" => hours_per_month,
            "hours_per_year" => hours_per_year
          } = report}
       ) do
    all_hours = Map.put(all_hours, name, sum_hours(all_hours[name], hours))

    hours_per_month =
      Map.put(hours_per_month, name, sum_period_hours(hours_per_month[name], month, hours))

    hours_per_year =
      Map.put(hours_per_year, name, sum_period_hours(hours_per_year[name], year, hours))

    {:ok, map_build(all_hours, hours_per_month, hours_per_year, report)}
  end

  defp sum_hours(nil, hours), do: hours
  defp sum_hours(hours_sum, hours), do: hours_sum + hours

  defp sum_period_hours(nil, period, hours), do: %{period => hours}

  defp sum_period_hours(name, period, hours),
    do: Map.put(name, period, sum_hours(name[period], hours))

  defp map_build(all_hours, hours_per_month, hours_per_year, report) do
    %{
      report
      | "all_hours" => all_hours,
        "hours_per_month" => hours_per_month,
        "hours_per_year" => hours_per_year
    }
  end
end
