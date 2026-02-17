defmodule ElixiriumTest do
  use ExUnit.Case
  doctest Elixirium

  test "greets the world" do
    assert Elixirium.hello() == :world
  end
end
