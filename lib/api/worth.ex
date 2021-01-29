defmodule Stonks.Api.Worth do
  @moduledoc false

  alias Stonks.Integration.Marketstack
  alias Stonks.Api.Common.Math

  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn = %{ body_params: %{
    "initial_balance" => initial_balance,
    "start_date" => start_date,
    "portfolio_allocation" => portfolio_allocation
  }}, _opts) do

    markets =
      portfolio_allocation
      |> build_portfolio_allocation()
      |> Marketstack.get_markets(start_date)

    potential_gain =
      Math.potential_gain(
        initial_balance,
        portfolio_allocation,
        markets
      )

    json_resp =
      build_response(potential_gain)


    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, json_resp)
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  #TODO: handle unhappy path
  defp build_response(potential_gain) do
    Poison.encode!(potential_gain)
  end

  defp build_portfolio_allocation(list) do
    Enum.reduce(list, [], fn pair, acc ->
      acc ++ [pair["symbol"]]
    end)
  end
end
