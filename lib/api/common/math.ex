defmodule Stonks.Api.Common.Math do
  @moduledoc false

  # TODO: Swap Floats for Decimals

  def potential_gain(
        initial_balance,
        portfolio_allocation,
        historical_markets
      ) do
    Enum.reduce(
      historical_markets,
      %{data: [], total: 0},
      fn {symbol, market}, acc ->
        %{"allocation" => percentage} =
          Enum.find(portfolio_allocation, fn p ->
            p
            |> Map.get("symbol")
            |> String.upcase() == symbol
          end)

        reserved_balance = percentage / 100 * initial_balance
        stock_num = reserved_balance / market["past_close"]
        current_stock_worth = stock_num * market["current_close"]

        new_data =
          acc.data ++
            [
              %{
                symbol: symbol,
                reserved_balance: reserved_balance,
                stock_num: stock_num,
                current_stock_worth: current_stock_worth,
                past_date: market["past_date"],
                current_date: market["current_date"],
                past_close: market["past_close"],
                current_close: market["current_close"]
              }
            ]

        new_total = acc.total + current_stock_worth

        %{acc | data: new_data, total: new_total}
      end
    )
  end
end
