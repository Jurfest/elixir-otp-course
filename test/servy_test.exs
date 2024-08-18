defmodule ServyTest do
  @doc """
  ExUinit is Elixir's built-in test framework.
  exs extends for Elixir script - which means they don't have to be compiled before they're run
  """
  use ExUnit.Case
  doctest Servy

  test "the truth" do
    assert 1 + 1 == 2
    refute 1 + 2 == 5
  end

  test "greets the world" do
    assert Servy.hello(:word) == "Howdy, word!"
  end
end
