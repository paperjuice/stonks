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
  * Same request can be made multiple times -> each time is going to be inserted in the DB
  """

  alias Stonks.Api
  alias Stonks.Storage

  require Logger

  def start(_type, _args) do
    Logger.info("Stonks started successfully")

    children = [
      {Plug.Cowboy, scheme: :http, plug: Api, options: [port: 9900]},
      Storage
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
