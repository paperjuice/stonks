defmodule Stonks.Api do
  @moduledoc false

  alias Stonks.Api.Endpoints.{
    Worth,
    HistoricalWorth
  }

  use Plug.Router

  plug(CORSPlug)
  plug(Stonks.Api.Log)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["text/*"],
    json_decoder: Poison
  )

  plug(:match)
  plug(:dispatch)

  get "/health" do
    send_resp(conn, 200, "big healthy boi")
  end

  post("/worth", to: Worth)

  get("/historical_worth/:key", to: HistoricalWorth)

  match _ do
    send_resp(conn, 404, "oops")
  end
end
