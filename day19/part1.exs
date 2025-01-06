require IEx

defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
  end
end

defmodule Helpers do
  def isFeasible({"", cache}, _), do: {true, cache}
  def isFeasible({val, cache}, patterns) do
    # IO.inspect(val, label: "val")
    # IO.inspect(cache, label: "cache")
    if Map.has_key?(cache, val) do
      # IO.inspect(cache[val], label: "cache")
      {cache[val], cache}
    else
      # IO.inspect(result, label: "result")
        matches = patterns |> Enum.filter(fn pattern -> String.starts_with?(val, pattern) end)
        {isOk, cache} = check_matches(matches, {val, cache}, patterns)
        # IO.inspect(val, label: "val")
        # IO.inspect(isOk, label: "isOk")
        cache = Map.put(cache, val, isOk)
        {isOk, cache}
    end
  end

  def check_matches([], {_, cache}, _), do: {false, cache}
  def check_matches(matches, {val, cache}, patterns) do
    matches |> Enum.reduce({nil, cache}, fn match, {_, cache} ->
      match_length = String.length(match)
      remaining = String.slice(val, match_length..-1)
      isFeasible({remaining, cache}, patterns)
    end)
  end
end

defmodule Main do
  def run(isTest) do
    [available | desired] = InputHelpers.parse(isTest)
    available = available |> String.split(", ")
    desired
    |> Enum.filter(fn des ->
      IO.inspect(des, label: "desired")
      {val,_} = Helpers.isFeasible({des, %{}}, available)
      # IO.inspect(val, label: "val")
      val
    end)
    |> length()
    |> IO.inspect(
      label:
        if isTest do
          "test result"
        else
          "real result"
        end
    )
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  @tag :skip
  test "Day 19 - Part 1 - test data" do
    assert Main.run(true) == 6
  end

  # @tag :skip
  test "Day 19 - Part 1 - real data" do
    assert Main.run(false) == 369
  end
end
