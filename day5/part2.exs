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

  def fix(page_set, rules) do
    IO.puts("fix")

    do_fix(
      page_set,
      rules
      |> Enum.filter(fn {a, b} -> Enum.member?(page_set, a) && Enum.member?(page_set, b) end)
    )
  end

  defp do_fix(pages, rules) do
    IO.inspect(pages, label: "pages")
    IO.inspect(rules, label: "rules")

    do_fix(pages, rules, get_violated_rule(pages, rules) |> IO.inspect(label: "violated rule"))
  end

  def get_invalid_page([], _) do
    nil
  end

  def get_invalid_page([page | other_pages], rules) do
    if is_page_valid(page, other_pages, rules) do
      get_invalid_page(other_pages, rules)
    else
      page
    end
  end

  def get_violated_rule([], _) do
    nil
  end

  def get_violated_rule([page | other_pages], rules) do
    violated_rule =
      rules
      |> Enum.filter(fn {a, _} -> a === page end)
      |> Enum.find(fn {_, b} -> !Enum.member?(other_pages, b) end)

    if violated_rule do
      violated_rule
    else
      get_violated_rule(other_pages, rules)
    end
  end

  defp do_fix(pages, _, nil) do
    pages
  end

  defp do_fix([h | t] = pages, rules, {invalid_page, insert_before}) do
    IO.inspect(invalid_page, label: "invalid page")
    IO.inspect(insert_before, label: "insert_before")
    pages = swap(pages, invalid_page, insert_before)
    do_fix(pages, rules, get_violated_rule(pages, rules))
  end

  defp swap(pages, invalid_page, insert_before) do
    pages = pages |> List.delete(invalid_page)
    IO.inspect(pages, label: "pages without invalid page")

    # dbg()
    insert_before_index = pages |> Enum.find_index(fn page -> page === insert_before end)
    IO.inspect(insert_before_index, label: "insert_before_index")

    # dbg()
    {prev, next} =
      pages |> Enum.split(insert_before_index) |> IO.inspect(label: "prev, next")

    dbg()
    Enum.concat([prev, [invalid_page], next])
  end

  def find_middle(list) do
    Enum.at(list, floor(length(list) / 2))
  end
end

defmodule Main do
  def run(isTest) do
    {rules, pagesSets} = InputHelpers.parse(isTest) |> IO.inspect(label: "input")

    valid_sets =
      pagesSets
      |> Enum.filter(&Helpers.is_set_valid(&1, rules))
      |> Enum.map(&Enum.reverse/1)
      |> Enum.reject(&Helpers.is_set_valid(&1, rules))
      |> Enum.map(&Enum.reverse/1)
      |> IO.inspect(label: "valid sets")

    pagesSets
    |> Enum.reject(fn set -> Enum.member?(valid_sets, set) end)
    |> IO.inspect(label: "invalid sets")
    |> Enum.map(&Helpers.fix(&1, rules))
    |> IO.inspect(label: "fixed set")
    |> Enum.map(&Helpers.find_middle/1)
    |> IO.inspect(label: "middle values")
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

Main.run(true)

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 5 - Part 1 - test data" do
    assert Main.run(true) == 123
  end

  # @tag :skip
  test "Day 5 - Part 1 - real data" do
    assert Main.run(false) == 5479
  end
end
