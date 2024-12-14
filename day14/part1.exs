defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(fn part ->
        part
        |> String.slice(2..-1)
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> List.to_tuple()
    end)
  end
end

defmodule Helpers do
  def calculate_position({{x, y}, {vx, vy}}, cols, rows, t) do
    x = rem(x + vx * t, cols)
    y = rem(y + vy * t, rows)

    {if(x < 0, do: cols + x, else: x), if(y < 0, do: rows + y, else: y)}
  end

  def filter_middle(coords, cols, rows) do
    x_to_remove = trunc(cols / 2)
    y_to_remove = trunc(rows / 2)

    coords
    |> Enum.filter(fn {x, y} -> x != x_to_remove && y != y_to_remove end)
  end

  def calculate_factor(positions, cols, rows) do
    middle_x = trunc(cols / 2)
    middle_y = trunc(rows / 2)

    positions
    |> Enum.filter(fn {x, y} -> x == trunc(x) && y == trunc(y) end)
    |> Enum.group_by(fn {x, y} ->
      cond do
        x < middle_x && y < middle_y -> 1
        x > middle_x && y < middle_y -> 2
        x > middle_x && y > middle_y -> 3
        x < middle_x && y > middle_y -> 4
      end
    end)
    |> Map.values()
    |> Enum.map(&length/1)
    |> Enum.reduce(1, fn v, t -> t * v end)
  end
end

defmodule Main do
  def run(isTest, cols, rows) do
    InputHelpers.parse(isTest)
    |> Enum.map(&Helpers.calculate_position(&1, cols, rows, 100))
    |> Helpers.filter_middle(cols, rows)
    |> Helpers.calculate_factor(cols, rows)
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
  test "Day 14 - Part 1 - test data" do
    assert Main.run(true, 11, 7) == 12
  end

  # @tag :skip
  test "Day 14 - Part 1 - real data" do
    assert Main.run(false, 101, 103) == 226_236_192
  end
end
