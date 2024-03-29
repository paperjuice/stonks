defmodule Stonks.Api.Endpoints.Worth do
  @moduledoc false

  @marketstack Application.compile_env(:stonks, :marketstack)
  @storage Application.compile_env(:stonks, :storage)

  alias Stonks.Api.Common.Math

  import Plug.Conn

  def init(options) do
    options
  end

  def call(
        conn = %{
          body_params: %{
            "initial_balance" => initial_balance,
            "start_date" => start_date,
            "portfolio_allocation" => portfolio_allocation
          }
        },
        _opts
      ) do
    symbols = build_portfolio_allocation(portfolio_allocation)

    with {:ok, markets} <- @marketstack.get_markets(symbols, start_date),
         potential_gain <- Math.potential_gain(initial_balance, portfolio_allocation, markets),
         {:ok, historical_key} <- @storage.insert_item(potential_gain),
         potential_gain <- Map.put(potential_gain, :historical_key, historical_key),
         {:ok, json_resp} <- Poison.encode(potential_gain) do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, json_resp)
    else
      {:error, msg} ->
        json_resp = build_error_resp(msg)

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, json_resp)
    end
  end

  def call(conn, _) do
    json_resp = build_error_resp("Unexpected request format")
    send_resp(conn, 422, json_resp)
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp build_portfolio_allocation(list) do
    Enum.reduce(list, [], fn pair, acc ->
      acc ++ [pair["symbol"]]
    end)
  end

  def build_error_resp(err) do
    # TODO: create a struct for error
    Poison.encode(%{reason: "#{inspect(err)}"})
  end
end
