defmodule Stonks do
  @moduledoc """
  Documentation for `Stonks`.
  TODO:
  * conventions
  * unit testing
  * benchmark (maybe)
  * travisci/semaphore (check if free sub)
  * coveralls
  * @type
  * credo
  * maybe dyalizer
  * docker
  * k8s (maybe)
  * heroku/gigalixir (ideally)
  * integration testing
  * async - sync req/resp
  * hypothetical balance
  * rebalancing (hopefully)
  * generate url + store in DB
  * FE (elm)
  * GIT flow (ticket, rebase, squash)


  ISSUES:
  * the market api will return [] data for multiple days/months
  in request param
  """

  alias Stonks.Integration.Marketstack.Async
  alias Stonks.Api

  def start(_type, _args) do
    IO.inspect("Started successfully")
    children = [
      {Plug.Cowboy, scheme: :http, plug: Api, options: [port: 9900]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
