defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.map(fn line -> String.split(line, "", trim: true) |> Enum.with_index() end)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, rowIndex} ->
      row |> Enum.map(fn {val, colIndex} -> {colIndex, rowIndex, val} end)
    end)
    |> Enum.reduce(%{}, fn {x, y, v}, acc -> acc |> Map.put({x, y}, v) end)
  end
end

defmodule Helpers do
  def start_group({_, result}, []) do
    result |> Enum.filter(fn x -> x !== [] end)
  end

  def start_group({matrix, result}, [key | _]) do
    add_to_group(key, matrix[key], matrix, [[] | result])
    |> start_group(Map.keys(matrix))
  end

  def add_to_group(_, value, matrix, result) when value === nil do
    {matrix, result}
  end

  def add_to_group({x, y} = key, value, matrix, [group | groups]) do
    result = [[{key, value} | group] | groups]
    matrix = Map.delete(matrix, key)

    [
      {x, y - 1},
      {x + 1, y},
      {x, y + 1},
      {x - 1, y}
    ]
    |> Enum.filter(fn nextKey ->
      matrix[nextKey] === value
    end)
    |> Enum.reduce({matrix, result}, fn key, {matrix, result} ->
      add_to_group(key, matrix[key], matrix, result)
    end)
  end

  def calculate(result) do
    result
    |> Enum.map(fn group -> {length(group), get_sides(group)} end)
    |> Enum.map(fn {area, sides} -> area * sides end)
    |> Enum.sum()
  end

  def get_sides(group) do
    group
    |> Enum.flat_map(&Helpers.get_corners/1)
    |> Helpers.get_vertexes(group)
    |> Enum.sort()
    |> Enum.dedup()
    |> length()
  end

  def get_corners({{x, y}, _}) do
    [
      {x, y},
      {x + 1, y},
      {x + 1, y + 1},
      {x, y + 1}
    ]
  end

  def get_vertexes(corners, group) do
    # a vertex is a corner where the ratio of occupied/free surrounding cells is odd
    corners
    |> Enum.filter(fn {x, y} ->
      occupied_adjacent =
        [
          {x, y},
          {x - 1, y},
          {x, y - 1},
          {x - 1, y - 1}
        ]
        |> Enum.filter(fn corner ->
          Enum.member?(group |> Enum.map(fn {{x, y}, _} -> {x, y} end), corner)
        end)
        |> length()

      cond do
        occupied_adjacent === 1 ->
          true

        occupied_adjacent === 2 ->
          false

        occupied_adjacent === 3 ->
          true

        occupied_adjacent === 4 ->
          false
      end
    end)
  end
end

defmodule Main do
  def run(isTest) do
    matrix = InputHelpers.parse(isTest)

    Helpers.start_group({matrix, []}, Map.keys(matrix))
    |> Helpers.calculate()
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

  # @tag :skip
  test "Day 12 - Part 2 - test data" do
    assert Main.run(true) == 1206
  end

  # @tag :skip
  test "Day 12 - Part 2 - real data" do
    assert Main.run(false) == 1_550_156
    # 939220 too low
  end
end
