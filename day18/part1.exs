require IEx

defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n")
    |> Enum.map(fn line ->
      String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end
end

defmodule Print do
  def print({index, movement, position, cols, rows}) do
    IO.puts("")
    IO.puts(movement)
    print_line(index, position, cols, rows, 0)
  end

  def print_line(index, position, cols, rows, row) do
    line = build_line(index, position, cols - 1, row, [])
    IO.puts(line)

    if row < rows do
      print_line(index, position, cols, rows, row + 1)
    end
  end

  def build_line(_, _, -1, _, line) do
    line |> Enum.join("")
  end

  def build_line(index, {posx, posy}, col, row, line) do
    build_line(index, {posx, posy}, col - 1, row, [
      if(col === posx && row === posy, do: "@", else: index[{col, row}]) | line
    ])
  end
end

defmodule Helpers do
  def dfs(stack, max, map, operation, history)

  def dfs([], _, _, _, history), do: history

  def dfs([{x, y} = key | stack], max, map, operation, history) do
    children =
      [{x, y + 1}, {x + 1, y}, {x, y - 1}, {x - 1, y}]
      |> Enum.filter(fn {x, y} ->
        x >= 0 && x <= max && y >= 0 && y <= max && map[{x, y}] !== true &&
          !Enum.member?(history, {x, y})
      end)

    next(&dfs/5, stack, key, children, max, map, operation, history)
  end

  defp next(named_function, collection, key, children, max, map, operation, history) do
    # IO.inspect(key)

    case operation.(max, key, history) do
      {:stop, res} ->
        [res | history]

      {:continue, res} ->
        children
        |> Enum.reduce(
          collection,
          fn tree, acc -> tree_insert(acc, tree) end
        )
        |> named_function.(max, map, operation, [res | history])
    end
  end

  defp tree_insert(collection, tree)
  defp tree_insert(collection, nil), do: collection
  defp tree_insert(stack, tree), do: [tree | stack]
end

defmodule Main do
  def run({isTest, bytes, max}) do
    map =
      InputHelpers.parse(isTest)
      |> Enum.take(bytes)
      |> Enum.reduce(%{}, fn [x, y], acc -> acc |> Map.put({x, y}, true) end)
      |> IO.inspect(label: "map")

    Helpers.dfs(
      [{0, 0}],
      max,
      map,
      fn max, {x, y}, _ ->
        if x === max && y === max, do: {:stop, {x, y}}, else: {:continue, {x, y}}
      end,
      []
    )
    |> IO.inspect(label: "path")
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

  # @tag :skip
  test "Day 18 - Part 1 - test data" do
    assert Main.run({true, 12, 6}) == 22
  end

  @tag :skip
  test "Day 18 - Part 1 - real data" do
    assert Main.run({false, 1024, 70}) == 1_437_174
  end
end
