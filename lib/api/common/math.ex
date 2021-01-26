defmodule Stonks.Api.Common.Math do
  @moduledoc false

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

  def potential_gain(
    initial_balance,
    portfolio_allocation,
    historical_markets
  ) do

    state = %{
      "total" => 0
    }

    historical_markets
    |> Enum.reduce(state, fn {symbol, market}, acc ->
      {_, percentage} =
        Enum.find(portfolio_allocation, fn {k, _} ->
          String.upcase(k) == symbol
        end)

      reserved_balanced = percentage / 100 * initial_balance
      stock_num = reserved_balanced / market["past_close"]
      current_stock_worth = stock_num * market["current_close"]

        acc
        |> Map.put("total", Float.round(acc["total"] + current_stock_worth, 2))
        |> Map.put(symbol, current_stock_worth)
    end)
  end
end
