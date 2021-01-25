defmodule StonksTest do
  use ExUnit.Case
  doctest Stonks

  test "greets the world" do
    assert Stonks.hello() == :world
  end
end
