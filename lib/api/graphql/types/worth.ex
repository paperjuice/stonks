defmodule Stonks.Api.GraphQL.Types.Worth do
  @moduledoc false

  use Absinthe.Schema.Notation

  object :worth do
    field(:data, list_of(:stock))
    field(:historical_key, non_null(:string))
    field(:total, :float)
  end

  object :stock do
    field(:current_close, :float)
    field(:current_date, :datetime)
    field(:current_stock_worth, :float)
    field(:past_close, :float)
    field(:past_date, :datetime)
    field(:reserved_balance, :float)
    field(:stock_num, :float)
    field(:symbol, :string)
  end

  input_object :portfolio_allocation do
    field(:symbol, non_null(:string))
    field(:allocation, non_null(:float))
  end
end
