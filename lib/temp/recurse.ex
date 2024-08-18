defmodule Recurse do
  def sum([head | tail], total) do
    sum(tail, total + head)
  end

  def sum([], total), do: total

  # def triple([head | tail]) do
  #   [head * 3 | triple(tail)]
  # end

  # def triple([]), do: []

  def triple(list) do
    triple(list, [])
  end

  defp triple([head | tail], current_list) do
    triple(tail, [head * 3 | current_list])
  end

  defp triple([], current_list) do
    current_list |> Enum.reverse()
  end

  # my_map
  # def my_map([head | tail], anonymous_func) do
  #   my_map([head | tail], anonymous_func, [])
  # end

  # def my_map([head | tail], anonymous_func, current_list) do
  #   my_map(tail, anonymous_func, [anonymous_func.(head) | current_list])
  # end

  # def my_map([], _, current_list) do
  #   current_list |> Enum.reverse()
  # end

  def my_map([head|tail], fun) do
    [fun.(head) | my_map(tail, fun)]
  end

  def my_map([], _fun), do: []
end

IO.puts(Recurse.sum([1, 2, 3, 4, 5], 0))
IO.inspect(Recurse.triple([1, 2, 3, 4, 5]))
IO.inspect(Recurse.my_map([1, 2, 3, 4, 5], &(&1 * 5)))
