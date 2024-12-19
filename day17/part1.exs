require IEx
import Bitwise

defmodule Helpers do
  def run(a, b, c, instructions, pointer, result) do
    instruction = Enum.at(instructions, pointer)

    if instruction === nil do
      {a, b, c, result |> Enum.reverse()}
    else
      operand = Enum.at(instructions, pointer + 1)
      {a, b, c, instruction, operand, result, pointer}
      {a, b, c, result, pointer} = exec(a, b, c, instruction, operand, result, pointer)
      run(a, b, c, instructions, pointer, result)
    end
  end

  def exec(a, b, c, instruction, operand, result, pointer) do
    case instruction do
      0 ->
        {trunc(a / Integer.pow(2, parse_combo(operand, a, b, c))), b, c, result, pointer + 2}

      1 ->
        {a, bxor(b, operand), c, result, pointer + 2}

      2 ->
        {a, rem(parse_combo(operand, a, b, c), 8), c, result, pointer + 2}

      3 ->
        if a === 0, do: {a, b, c, result, pointer + 2}, else: {a, b, c, result, operand}

      4 ->
        {a, bxor(b, c), c, result, pointer + 2}

      5 ->
        {a, b, c, [rem(parse_combo(operand, a, b, c), 8) | result], pointer + 2}

      6 ->
        {a, trunc(a / Integer.pow(2, parse_combo(operand, a, b, c))), c, result, pointer + 2}

      7 ->
        {a, b, trunc(a / Integer.pow(2, parse_combo(operand, a, b, c))), result, pointer + 2}
    end
  end

  def parse_combo(operand, a, b, c) do
    case operand do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
      4 -> a
      5 -> b
      6 -> c
      7 -> :invalid
    end
  end
end

defmodule Main do
  def run(a, b, c, instructions) do
    Helpers.run(a, b, c, instructions, 0, [])
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  @tag :skip
  test "Day 16 - Part 1 - 1" do
    {_, b, _, _} = Main.run(nil, nil, 9, [2, 6])
    assert b == 1
  end

  @tag :skip
  test "Day 16 - Part 1 - 2" do
    {_, _, _, r} = Main.run(10, nil, nil, [5, 0, 5, 1, 5, 4])
    assert r == [0, 1, 2]
  end

  test "Day 16 - Part 1 - 3" do
    {a, _, _, r} = Main.run(2024, nil, nil, [0, 1, 5, 4, 3, 0])
    assert r == [4, 2, 5, 6, 7, 7, 7, 7, 3, 1, 0] && a === 0
  end

  test "Day 16 - Part 1 - 4" do
    {_, b, _, _} = Main.run(nil, 29, nil, [1, 7])
    assert b === 26
  end

  test "Day 16 - Part 1 - 5" do
    {_, b, _, _} = Main.run(nil, 2024, 43690, [4, 0])
    assert b === 44354
  end

  # @tag :skip
  test "Day 16 - Part 1 - test data" do
    {_, _, _, r} = Main.run(729, 0, 0, [0, 1, 5, 4, 3, 0])
    assert r === [4, 6, 3, 5, 6, 3, 5, 2, 1, 0]
  end

  # @tag :skip
  test "Day 16 - Part 1 - real data" do
    {_, _, _, r} = Main.run(30_118_712, 0, 0, [2, 4, 1, 3, 7, 5, 4, 2, 0, 3, 1, 5, 5, 5, 3, 0])
    assert r |> Enum.join(",") === "1,7,6,5,1,0,5,0,7"
  end
end
