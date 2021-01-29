defmodule Stonks.Api.Common.Math do
  @moduledoc """
  TODO: Swap Floats for Decimals
  """

  @c 32500

@a  %{
  "AAPL" => %{
    "current_close" => 142.92,
    "current_date" => "2021-01-25T00:00:00+0000",
    "past_close" => 97.3768435044,
    "past_date" => "2020-07-15T00:00:00+0000"
  },
  "GOOG" => %{
    "current_close" => 1899.4,
    "current_date" => "2021-01-25T00:00:00+0000",
    "past_close" => 1513.64,
    "past_date" => "2020-07-15T00:00:00+0000"
  }
}
  @b %{"aapl" => 20, "goog" => 80}

  @d [
    %{
      symbols: "AAPL",
      reserved_balance: 6000,
      num_of_stocks_to_buy: 2.2,
      current_stocks_worth: 8322,
      past_date: "",
      current_date: "",
      past_close: 96,
      current_close: 114
    }
  ]

  def potential_gain(
    initial_balance,
    portfolio_allocation,
    historical_markets
  ) do
    historical_markets
    |> Enum.reduce(%{data: [], total: 0}, fn {symbol, market}, acc ->
      %{"allocation" => percentage} =
        Enum.find(portfolio_allocation, fn p ->
          p
          |> Map.get("symbol")
          |> String.upcase() == symbol
        end)

      reserved_balance = percentage / 100 * initial_balance
      stock_num = reserved_balance / market["past_close"]
      current_stock_worth = stock_num * market["current_close"]

      new_data = acc.data ++ [
          %{
            symbol: symbol,
            reserved_balance: reserved_balance,
            stock_num:  stock_num,
            current_stock_worth: current_stock_worth,
            past_date: market["past_date"],
            current_date: market["current_date"],
            past_close: market["past_close"],
            current_close: market["current_close"]
          }
        ]

      new_total = acc.total + current_stock_worth

      %{acc | data: new_data, total: new_total}
    end)
  end
end
