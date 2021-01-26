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
      |> Map.keys()
      |> Marketstack.get_markets(start_date)

    potential_gain =
      Math.potential_gain(
        initial_balance,
        portfolio_allocation,
        markets
      )

    json_resp =
      build_response(markets, potential_gain)


    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, json_resp)
  end


  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------

  defp build_response(markets, potential_gain) do
    resp_markets=
      Enum.map(markets, fn {k, market} ->
        %{
          current_close: market["current_close"],
          current_date: market["current_date"],
          past_close: market["past_close"],
          past_date: market["past_date"],
          potential_gain: Map.get(potential_gain, k)
        }
      end)

    Poison.encode!(
      %{
        total: potential_gain["total"],
        markets: resp_markets
      }
    )

  end
end
