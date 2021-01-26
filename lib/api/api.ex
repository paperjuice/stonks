defmodule Stonks.Api do
  @moduledoc false

  use Plug.Router

  plug Plug.Parsers, parsers: [:urlencoded, :json],
                   pass: ["text/*"],
                   json_decoder: Poison
  plug :match
  plug :dispatch

  get "/health" do
    send_resp(conn, 200, "big healthy boi")
  end

  post "/worth", to: Stonks.Api.Worth

  match _ do
    send_resp(conn, 404, "oops")
  end
end
