defmodule Stonks do
  @moduledoc """
  Stonks is an application that allows the user to input an initial financial balance, a date in a past and portfolio allocation.
  The response generated will contain how much the stocks requested are worth today.
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
