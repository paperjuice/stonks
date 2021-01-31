defmodule Stonks.Api.Log do
  @moduledoc """
  Shared plug that logs each established connection
  """

  require Logger

  def init([]), do: false
  def call(conn, _opts) do
    Logger.info("Request successfully registerd for #{inspect(conn.request_path)} endpoint.")

    conn
  end
end
