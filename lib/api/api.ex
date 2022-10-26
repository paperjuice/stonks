defmodule Stonks.Api do
  @moduledoc false

  alias Stonks.Api.Endpoints.{
    Fail,
    HistoricalWorth,
    Worth
  }

  use Plug.Router

  plug(CORSPlug)
  plug(Stonks.Api.Log)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    json_decoder: Poison
  )

  forward("/graphiql", to: Absinthe.Plug.GraphiQL, schema: Stonks.Api.GraphQL.Schema)

  plug(:match)
  plug(:dispatch)

  get "/health" do
    send_resp(conn, 200, "big healthy boi")
  end

  get("/fail", to: Fail)

  post("/worth", to: Worth)

  get("/historical_worth/:key", to: HistoricalWorth)

  match _ do
    send_resp(conn, 404, "oops")
  end
end
