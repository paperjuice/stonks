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
  """

  alias Stonks.Integration.Marketstack.Async

  def start(_type, _args) do
    children = [
      Async
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
