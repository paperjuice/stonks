defmodule Stonks.Api.Endpoints.Fail do
  @moduledoc false
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, opts) do
    Poison.decode!(nil)

    send_resp(conn, 200, "{}")
  end
end
