defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn chunk ->
      chunk
      |> Enum.reduce({{nil, nil}, {nil, nil}, {nil, nil}}, &decode_line/2)
    end)
  end

  def decode_line("Button A: " <> rest, {_, b, p}) do
    {decode_data(rest), b, p}
  end

  def decode_line("Button B: " <> rest, {a, _, p}) do
    {a, decode_data(rest), p}
  end

  def decode_line("Prize: " <> rest, {a, b, _}) do
    {a, b, decode_data(rest)}
  end

  def decode_data(rest) do
    rest
    |> String.split(", ", trim: true)
    |> Enum.map(fn str ->
      str |> String.slice(2..-1) |> String.to_integer()
    end)
    |> List.to_tuple()
  end
end

defmodule Helpers do
  def solve({{ax, ay}, {bx, by}, {px, py}}) do
    a = (px * by - py * bx) / (ax * by - ay * bx)

    if a == trunc(a) do
      b = (px - a * ax) / bx
      {a, b}
    else
      false
    end
  end

  def calculate(solutions) do
    successes =
      solutions
      |> Enum.filter(&Function.identity/1)

    successes
    |> Enum.map(fn {a, b} -> a * 3 + b end)
    |> Enum.sum()
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Enum.map(&Helpers.solve/1)
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
  test "Day 13 - Part 1 - test data" do
    assert Main.run(true) == 480
  end

  # @tag :skip
  test "Day 13 - Part 1 - real data" do
    assert Main.run(false) == 28887
  end
end
