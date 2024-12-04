defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> linesToMap()
  end

  def linesToMap(lines) do
    lines
    |> Enum.map(fn line -> String.split(line, "", trim: true) |> Enum.with_index() end)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, rowIndex} ->
      row |> Enum.map(fn {val, colIndex} -> {colIndex, rowIndex, val} end)
    end)
    |> Enum.reduce(%{}, fn {x, y, v}, acc -> acc |> Map.put({x, y}, v) end)
  end
end

defmodule Helpers do
  def get_a_coords(matrix) do
    matrix
    |> Map.to_list()
    |> Enum.filter(fn {_, v} -> v === "A" end)
  end

  def matches({{x, y}, v}, matrix) do
    one =
      [
        matrix[{x - 1, y - 1}] || ".",
        v,
        matrix[{x + 1, y + 1}] || "."
      ]
      |> List.to_string()

    two =
      [
        matrix[{x - 1, y + 1}] || ".",
        v,
        matrix[{x + 1, y - 1}] || "."
      ]
      |> List.to_string()

    (one === "MAS" || one === "SAM") && (two === "MAS" || two === "SAM")
  end
end

defmodule Main do
  def run(isTest) do
    matrix = InputHelpers.parse(isTest)

    result =
      matrix
      |> Helpers.get_a_coords()
      |> Enum.filter(&Helpers.matches(&1, matrix))
      |> length()
      |> IO.inspect(
        label:
          if isTest do
            "test result"
          else
            "real result"
          end
      )

    result
  end
end

Main.run(true)

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 4 - Part 2 - test data" do
    assert Main.run(true) == 9
  end

  # @tag :skip
  test "Day 4 - Part 2 - real data" do
    assert Main.run(false) == 1875
  end
end
