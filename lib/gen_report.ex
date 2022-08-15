defmodule GenReport do
  alias GenReport.Parser

  def build(), do: {:error, "Insira o nome de um arquivo"}

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(
      {:ok, %{"all_hours" => %{}, "hours_per_month" => %{}, "hours_per_year" => %{}}},
      fn line, report -> report_construct(line, report) end
    )
  end

  def build_from_many(), do: {:error, "Insira uma lista com nome de arquivos"}

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(%{}, fn {:ok, result}, report -> sum_reports(result, report) end)

    {:ok, result}
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

  defp sum_reports(
         {:ok,
          %{
            "all_hours" => result_all_hours,
            "hours_per_month" => result_hours_per_month,
            "hours_per_year" => result_hours_per_year
          } = result},
         report
       ) do
    case report do
      %{} when report == %{} ->
        result

      %{
        "all_hours" => report_all_hours,
        "hours_per_month" => report_hours_per_month,
        "hours_per_year" => report_hours_per_year
      } ->
        all_hours = merge_maps(result_all_hours, report_all_hours)
        hours_per_month = merge_maps(result_hours_per_month, report_hours_per_month)
        hours_per_year = merge_maps(result_hours_per_year, report_hours_per_year)
        map_build(all_hours, hours_per_month, hours_per_year, report)
    end
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn
      _key, value1, value2 when not is_map(value1) or not is_map(value2) -> value1 + value2
      _key, value1, value2 -> merge_maps(value1, value2)
    end)
  end
end
