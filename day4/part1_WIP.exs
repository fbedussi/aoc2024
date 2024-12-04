defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.map(fn line -> String.split(line, "", trim: true) end)
    |> IO.inspect(label: "input")
  end
end

defmodule Helpers do
  def findInString(str) do
    [Regex.scan(~r/XMAS/, str) | Regex.scan(~r/SAMX/, str) ]|> length()
  end

  def convertToColumns(rows) do
    rows
      |> Enum.zip_with(&Function.identity/1)
  end

  def rotate(matrix) do
    # Get the number of rows and columns
    num_rows = length(matrix)
    num_cols = length(List.first(matrix))

    # Initialize an empty list of lists for the rotated matrix
    diagonals = for _ <- 0..(num_rows + num_cols - 2), do: []

    # Iterate through each element in the matrix and place it into the corresponding diagonal
    for row <- 0..(num_rows - 1) do
      for col <- 0..(num_cols - 1) do
        # Calculate the diagonal index
        diagonal_index = row + col

        # Update the correct diagonal list with the element
        diagonals = List.update_at(diagonals, diagonal_index, fn diagonal ->
          diagonal ++ [Enum.at(matrix, row) |> Enum.at(col)]
        end)
      end
    end

    # Return the resulting rotated matrix
    diagonals
  end
end

defmodule Main do
  def run(isTest) do
    rows = InputHelpers.parse(isTest)
    occurrencesInRows = rows
      |> Enum.map(&List.to_string/1)
      |> Enum.map(&Helpers.findInString/1)
      |> Enum.sum()
    occurrencesInColumns = rows
      |> Helpers.convertToColumns()
      |> Enum.map(&List.to_string/1)
      |> Enum.map(&Helpers.findInString/1)
      |> Enum.sum()

    occurrencesInRows + occurrencesInColumns
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  test "convertToColumns" do
    assert Helpers.convertToColumns([
      ["A", "B"],
      ["C", "D"],
      ["E", "F"]
    ]) === [
      ["A", "C", "E"],
      ["B", "D", "F"]
    ]
  end

  test "roteate +45" do
    assert Helpers.rotate([
      ["A", "B", "C"],
      ["D", "E", "F"],
      ["G", "H", "I"]
    ]) === [
      ["A", "E", "I"],
      ["B", "F"],
      ["C"],
      ["D", "H"],
      ["G"],
    ]
  end

  test "findInString" do
    assert Helpers.findInString("XMASAMX.MM") === 2
  end

  @tag :skip
  test "Day 3 - Part 1 - test data" do
    assert Main.run(true) == 18
  end

  @tag :skip
  test "Day 3 - Part 1 - real data" do
    assert Main.run(false) == 536
  end
end
