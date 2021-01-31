defmodule Stonks.Integration.MarketstackTest do
  @moduledoc false

  alias Stonks.Integration.Shared.HttpMock
  alias Stonks.Integration.Marketstack

  import Mox

  use ExUnit.Case, async: false

  setup :verify_on_exit!

  describe "#get_markets/2" do
    setup do
      symbols = ["AAPL", "GOOG"]
      past_date = "2013-02-01"

      %{
        symbols: symbols,
        past_date: past_date
      }
    end

    test "returns success", %{
      past_date: past_date,
      symbols: symbols
    } do
      expect(HttpMock, :get, fn _ ->
        {:ok, %{body: mock_past()}}
      end)

      expect(HttpMock, :get, fn _ ->
        {:ok, %{body: mock_current()}}
      end)

      {:ok, data} = Marketstack.get_markets(symbols, past_date)

      assert data["AAPL"] == %{
        "current_close" => 142.92,
        "current_date" => "2021-01-25T00:00:00+0000",
        "past_close" => 97.3768435044,
        "past_date" => "2020-07-15T00:00:00+0000"
      }
      assert data["GOOG"] == %{
        "current_close" => 1899.4,
        "current_date" => "2021-01-25T00:00:00+0000",
        "past_close" => 1513.64,
        "past_date" => "2020-07-15T00:00:00+0000"
      }
    end
  end

  defp mock_past do
    "{\"pagination\":{\"limit\":2,\"offset\":0,\"count\":2,\"total\":238},\"data\":[{\"open\":395.96,\"high\":396.99,\"low\":385.96,\"close\":390.9,\"volume\":38306874.0,\"adj_high\":98.893919424,\"adj_low\":96.1462433333,\"adj_close\":97.3768435044,\"adj_open\":98.6373367972,\"adj_volume\":153227496.0,\"symbol\":\"AAPL\",\"exchange\":\"XNAS\",\"date\":\"2020-07-15T00:00:00+0000\"},{\"open\":1523.13,\"high\":1535.33,\"low\":1498.0,\"close\":1513.64,\"volume\":1761000.0,\"adj_high\":1535.33,\"adj_low\":1498.0,\"adj_close\":1513.64,\"adj_open\":1523.13,\"adj_volume\":1761000.0,\"symbol\":\"GOOG\",\"exchange\":\"XNAS\",\"date\":\"2020-07-15T00:00:00+0000\"}]}"
  end

  defp mock_current do
    "{\"pagination\":{\"limit\":2,\"offset\":0,\"count\":2,\"total\":504},\"data\":[{\"open\":1920.67,\"high\":1929.58,\"low\":1867.53,\"close\":1899.4,\"volume\":1925807.0,\"adj_high\":1929.58,\"adj_low\":1867.53,\"adj_close\":1899.4,\"adj_open\":1920.67,\"adj_volume\":1925807.0,\"symbol\":\"GOOG\",\"exchange\":\"XNAS\",\"date\":\"2021-01-25T00:00:00+0000\"},{\"open\":143.07,\"high\":145.09,\"low\":136.54,\"close\":142.92,\"volume\":157611713.0,\"adj_high\":145.09,\"adj_low\":136.54,\"adj_close\":142.92,\"adj_open\":143.07,\"adj_volume\":157611713.0,\"symbol\":\"AAPL\",\"exchange\":\"XNAS\",\"date\":\"2021-01-25T00:00:00+0000\"}]}"
  end
end
