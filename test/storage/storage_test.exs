defmodule Stonks.Storage.StorageTest do
  @moduledoc false

  alias Stonks.Storage

  import Mox

  use ExUnit.Case, async: false

  setup :verify_on_exit!

  describe "api" do
    test "returns success for both get & insert" do
      {:ok, key} = Storage.insert_item(:value)
      [{actual_key, actual_value}] = Storage.get_item(key)

      assert actual_value == :value
      assert actual_key == key
    end
  end
end
