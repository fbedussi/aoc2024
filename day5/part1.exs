defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    {rules, page_sets} =
      rawData
      |> String.split("\n", trim: true)
      |> Enum.split_with(fn line -> line |> String.contains?("|") end)

    rules =
      rules
      |> Enum.map(fn rule ->
        String.split(rule, "|", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)

    page_sets =
      page_sets
      |> Enum.map(fn line ->
        String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)
      end)

    {rules, page_sets}
  end
end

defmodule Helpers do
  def is_set_valid(page_set, rules) do
    do_is_set_valid(
      page_set,
      rules
      |> Enum.filter(fn {a, b} -> Enum.member?(page_set, a) && Enum.member?(page_set, b) end)
    )
  end

  def do_is_set_valid([_ | []], _) do
    true
  end

  def do_is_set_valid([page | other_pages], rules) do
    if is_page_valid(page, other_pages, rules) do
      do_is_set_valid(other_pages, rules)
    else
      false
    end
  end

  defp is_page_valid(page, other_pages, rules) do
    rules
    |> Enum.filter(fn {a, _} -> a === page end)
    |> Enum.all?(fn {_, b} -> other_pages |> Enum.member?(b) end)
  end

  def find_middle(list) do
    Enum.at(list, floor(length(list) / 2))
  end
end

defmodule Main do
  def run(isTest) do
    {rules, pagesSets} = InputHelpers.parse(isTest)

    pagesSets
    |> Enum.filter(&Helpers.is_set_valid(&1, rules))
    |> Enum.map(&Enum.reverse/1)
    |> Enum.reject(&Helpers.is_set_valid(&1, rules))
    |> Enum.map(&Helpers.find_middle/1)
    |> Enum.sum()
    |> IO.inspect(
      label:
        if isTest do
          "test result:"
        else
          "real result:"
        end
    )
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 5 - Part 1 - test data" do
    assert Main.run(true) == 143
  end

  # @tag :skip
  test "Day 5 - Part 1 - real data" do
    assert Main.run(false) == 5991
  end
end
