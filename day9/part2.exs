defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.map(fn line -> line |> String.split("", trim: true) end)
    |> Enum.map(fn line -> line |> Enum.with_index() end)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, rowIndex} ->
      row |> Enum.map(fn {val, colIndex} -> {colIndex, rowIndex, val} end)
    end)
  end
end

defmodule Helpers do
  def getValidNodesByGroup({_, coords}, max_x, max_y) do
    getNodesByGroup([], coords, max_x, max_y)
    |> Enum.filter(fn {x, y} -> x >= 0 && x <= max_x && y >= 0 && y <= max_y end)
  end

  defp getNodesByGroup(result, [], _, _) do
    result
  end

  defp getNodesByGroup(result, [a | rest], max_x, max_y) do
    updated_result =
      rest
      |> Enum.flat_map(fn b -> getNodes(a, b, max_x, max_y) end)
      |> Enum.concat(result)

    getNodesByGroup(updated_result, rest, max_x, max_y)
  end

  defp getNodes({xa, ya}, {xb, yb}, max_x, max_y) do
    dx = xb - xa
    dy = yb - ya

    getNodes([{xa, ya}, {xb, yb}], 1, {xa, ya}, {xb, yb}, dx, dy, max_x, max_y)
  end

  defp getNodes(result, n, {xa, ya}, {xb, yb}, dx, dy, max_x, max_y) do
    new_points = [{xa - dx * n, ya - dy * n}, {xb + dx * n, yb + dy * n}]

    if(new_points |> Enum.all?(fn {x, y} -> (x < 0 || x > max_x) && (y < 0 || y > max_y) end)) do
      result
    else
      getNodes(Enum.concat(result, new_points), n + 1, {xa, ya}, {xb, yb}, dx, dy, max_x, max_y)
    end
  end
end

defmodule Main do
  def run(isTest) do
    coords = InputHelpers.parse(isTest)

    max_x =
      coords
      |> Enum.map(fn {x, _, _} -> x end)
      |> Enum.max()

    max_y =
      coords
      |> Enum.map(fn {_, y, _} -> y end)
      |> Enum.max()

    coords_by_antenna =
      coords
      |> Enum.group_by(fn {_, _, v} -> v end, fn {x, y, _} -> {x, y} end)
      |> Map.delete(".")

    coords_by_antenna
    |> Enum.flat_map(&Helpers.getValidNodesByGroup(&1, max_x, max_y))
    |> Enum.sort()
    |> Enum.dedup()
    |> length()
    |> IO.inspect(label: if(isTest, do: "test result: ", else: "real result: "))
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 8 - Part 1 - test data" do
    assert Main.run(true) == 34
  end

  # @tag :skip
  test "Day 8 - Part 1 - real data" do
    assert Main.run(false) == 1277
  end
end
