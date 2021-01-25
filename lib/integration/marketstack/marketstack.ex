defmodule Stonks.Integration.Marketstack do
  @moduledoc false

  alias Stonks.Integration.Marketstack.Async

  def get_response do
    # TODO: This will fail so keep in mind for unhappy path
    # url = "http://api.marketstack.com/v1/eod?access_key=#{key}&symbols=AAPL&date_from= 2020-01-01"

    # url = "http://api.marketstack.com/v1/eod?access_key=#{key}&symbols=AAPL&date_from=2020-02-05&date_to=2020-02-07&limit=1"
    # url = "http://api.marketstack.com/v1/eod?access_key=#{key}&symbols=AAPL&date_to=2020-02-07&limit=1"
    # url = "http://api.marketstack.com/v1/eod?access_key=7dec887e6dc1144dfc581840c90f5641&date_to=2020-02-09&symbols=AAPL,GOOG&limit=2"
    # url = "http://api.marketstack.com/v1/eod?access_key=#{key}&symbols=AAPL&limit=2"
    #    |> IO.inspect(label: Async.Async_request)
    #    %{body: body} = HTTPoison.get!(url)
    #    Poison.decode!(body)

    symbols = ["AAPL", "GOOG"]
    past_date = "2020-01-01"

    Async.async_request(%{symbols: symbols, past_date: past_date})
  end
end
