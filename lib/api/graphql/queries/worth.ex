defmodule Stonks.Api.GraphQL.Queries.Worth do
  @moduledoc false

  alias Stonks.Api.GraphQL.Resolvers
  use Absinthe.Schema.Notation

  object :worth_queries do
    @desc "Get worth based on date, balance for a list of stocks"

    field :worth, :worth do
      arg(:initial_balance, non_null(:float))
      arg(:start_date, non_null(:date))
      arg(:portfolio_allocations, :portfolio_allocation |> list_of() |> non_null())

      resolve(&Resolvers.Worth.get/3)
    end
  end
end
