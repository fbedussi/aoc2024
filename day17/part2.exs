require IEx
import Bitwise

defmodule Helpers do
  def find_a(a, b, c, instructions, pointer, result) do
    # IO.puts(a)

    if rem(bxor(bxor(3, trunc(a / 8)), 5), 8) === 2 && trunc(a / 8) != 0 &&
         rem(bxor(bxor(rem(trunc(a / 8), 8), 3), 5), 8) === 4 do
      a
    else
      find_a(a + 1, b, c, instructions, pointer, result)
    end

    # 27434144 low
  end

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
    Helpers.find_a(a, b, c, instructions, 0, [])
    |> IO.inspect(label: "result")
  end
end

Main.run(31_285_831, 0, 0, [2, 4, 1, 3, 7, 5, 4, 2, 0, 3, 1, 5, 5, 5, 3, 0])

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  @tag :skip
  test "Day 17 - Part 2 - test data" do
    assert Main.run(0, 0, 0, [0, 3, 5, 4, 3, 0]) === 117_440
  end

  @tag :skip
  test "Day 17 - Part 2 - real data" do
    assert Main.run(27_434_138, 0, 0, [
             2,
             4,
             1,
             3,
             7,
             5,
             4,
             2,
             0,
             3,
             1,
             5,
             5,
             5,
             3,
             0
           ]) === 0
  end
end

# brute force, arrivato a 27434137

# numero(pari(multiplo(di(8 + 2))))
