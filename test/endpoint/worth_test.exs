defmodule Stonks.Endpoint.WorthTest do
  @moduledoc false

  alias Stonks.Api.Endpoints.Worth
  alias Stonks.Integration.MarketstackMock
  alias Stonks.StorageMock

  import Mox

  use ExUnit.Case, async: false
  use Plug.Test

  setup :verify_on_exit!

  describe "#call/2" do
    test "returns success" do
      body = %{
        "initial_balance" => 1000,
        "start_date" => "2013-01-01",
        "portfolio_allocation" => [
          %{
            "symbol" => "aapl",
            "allocation" => 100
          }
        ]
      }

      conn = conn(:post, "/worth", body)

      expect(StorageMock, :insert_item, fn _ ->
        {:ok, "some_key"}
      end)

      expect(MarketstackMock, :get_markets, fn symbols, start_date ->
        assert symbols == ["aapl"]
        assert start_date == "2013-01-01"

        resp = %{
          "AAPL" => %{
            "current_close" => 131.96,
            "current_date" => "2021-01-29T00:00:00+0000",
            "past_close" => 228.6354758,
            "past_date" => "2020-03-20T00:00:00+0000"
          }
        }

        {:ok, resp}
      end)

      resp = Worth.call(conn, nil)

      assert resp.resp_body == Poison.encode!(success_resp())
      assert resp.status == 200
    end
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp success_resp do
    %{
      data: [
        %{
          current_close: 131.96,
          current_date: "2021-01-29T00:00:00+0000",
          current_stock_worth: 577.1632750266309,
          past_close: 228.6354758,
          past_date: "2020-03-20T00:00:00+0000",
          reserved_balance: 1.0e3,
          stock_num: 4.373774439425818,
          symbol: "AAPL"
        }
      ],
      historical_key: "some_key",
      total: 577.1632750266309
    }
  end
end
