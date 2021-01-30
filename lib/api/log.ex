defmodule Stonks.Api.Log do
  @moduledoc false

  require Logger

  def init([]), do: false
  def call(conn, _opts) do
    Logger.info("Request successfully registerd for #{inspect(conn.request_path)} endpoint.")

    conn
  end
end
