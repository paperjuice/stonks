defmodule Stonks.Api.Endpoints.HistoricalWorth do
  @moduledoc false
  alias Stonks.Storage
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn = %{params: %{"key" => key}}, _) do
    json_resp =
      case Storage.get_item(key) do
        [] -> Poison.encode!(%{data: [], total: 0})
        [{_key, value}] -> Poison.encode!(value)
      end

    send_resp(conn, 200, json_resp)
  end
end
