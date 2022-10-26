defmodule Stonks.Api.GraphQL.Resolvers.Worth do
  @moduledoc false

  alias Stonks.Api.Common.Math

  @marketstack Application.compile_env(:stonks, :marketstack)
  @storage Application.compile_env(:stonks, :storage)

  def get(
        _,
        %{
          initial_balance: initial_balance,
          portfolio_allocations: portfolio_allocations,
          start_date: start_date
        },
        _
      ) do
    # TODO: duplicate flow here and in Endpoints.Worth (DRY)
    symbols = build_portfolio_allocation(portfolio_allocations)
    parsed_portfolio_allocations = build_portfolio_allocations_params(portfolio_allocations)

    with {:ok, markets} <- @marketstack.get_markets(symbols, start_date),
         potential_gain <-
           Math.potential_gain(initial_balance, parsed_portfolio_allocations, markets),
         {:ok, historical_key} <- @storage.insert_item(potential_gain),
         worth <- Map.put(potential_gain, :historical_key, historical_key) do
      {:ok, worth}
    end
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp build_portfolio_allocation(list) do
    Enum.reduce(list, [], fn pair, acc ->
      acc ++ [pair[:symbol]]
    end)
  end

  defp build_portfolio_allocations_params(portfolio_allocations) do
    Enum.map(portfolio_allocations, fn %{symbol: sym, allocation: alloc} ->
      %{"symbol" => sym, "allocation" => alloc}
    end)
  end
end
