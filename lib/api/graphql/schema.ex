defmodule Stonks.Api.GraphQL.Schema do
  @moduledoc false
  alias Stonks.Api.GraphQL.Queries
  use Absinthe.Schema

  import_types(Queries.Worth)
  import_types(Stonks.Api.GraphQL.Types.Worth)

  query do
    import_fields(:worth_queries)
  end


  # ---------------------------------------------
  #                 SHARED TYPES
  # ---------------------------------------------
  # TODO: there is already and absinthe date type but
  # currently there is parsing from date string which
  # should happen at data validation level when we get response
  # from integrations. Also, I don't want to do that because
  # it breaks the contract between FE and the current Json API
  scalar :datetime do
    description("DateTime type (2022-10-25T00:00:00+0000)")
    parse(&parse_date(&1))
    serialize(&serialise_date(&1))
  end

  scalar :date do
    description("""
    The `Date` scalar type represents a date. The Date appears in a JSON
    response as an ISO8601 formatted string, without a time component.
    """)

    serialize(&Date.to_iso8601/1)
    parse(&parse_date/1)
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp parse_date(%{value: string_date}), do: {:ok, string_date}
  defp serialise_date(string_date), do: string_date
end
