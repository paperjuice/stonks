defmodule Stonks.Integration.Marketstack do
  @moduledoc false

  alias Stonks.Integration.Shared.Http

  # TODO: This wont work when api_key is part of sys env var
  @api_key Application.get_env(:stonks, :marketstack_api_key)

  def get_markets(symbols, past_date) do
    # TODO: This will fail so keep in mind for unhappy path
    # url = "http://api.marketstack.com/v1/eod?access_key=#{key}&symbols=AAPL&date_from= 2020-01-01"

    # url = "http://api.marketstack.com/v1/eod?access_key=#{key}&symbols=AAPL&date_from=2020-02-05&date_to=2020-02-07&limit=1"
    # url = "http://api.marketstack.com/v1/eod?access_key=#{key}&symbols=AAPL&date_to=2020-02-07&limit=1"
    # url = "http://api.marketstack.com/v1/eod?access_key=7dec887e6dc1144dfc581840c90f5641&date_to=2020-02-09&symbols=AAPL,GOOG&limit=2"
    # url = "http://api.marketstack.com/v1/eod?access_key=#{key}&symbols=AAPL&limit=2"
    #    |> IO.inspect(label: Async.Async_request)
    #    %{body: body} = HTTPoison.get!(url)
    #    Poison.decode!(body)

  async_requests(symbols, past_date)

    #Async.async_request(%{symbols: symbols, past_date: past_date})
  end

  #  The purpose of this module is to send 2 requests to marketstack async
  #  From their documentation doesn't seem to exist a way to get a stock from the past and
  #  another one from present (list with to obj)
  defp async_requests(symbols, past_date) do
    past_request = Task.async(fn -> request(symbols, past_date) end)
    current_request = Task.async(fn -> request(symbols) end)

    tasks_with_results = Task.yield_many([past_request, current_request], 5000)

    [past_result, current_result] =
      Enum.map(tasks_with_results, fn {task, res} ->
        # Shut down the tasks that did not reply nor exit
        res || Task.shutdown(task, :brutal_kill)
      end)



    # Order is guaranteed
    with {:ok, past_stocks} <- handle_response(past_result),
         {:ok, current_stocks} <- handle_response(current_result),
         data <- build_past_data(past_stocks),
         {:ok, full} <- build_current_data(data, current_stocks) do
      full
    end
  end


  def handle_response(nil), do: {:error, :timeout}
  def handle_response({:ok, {:ok, %{body: body}}}) do
    Poison.decode(body)
  end

  #I use adj_close instead of close because I saw big discrepancies between `close`
  #and all the other values
  defp build_past_data(%{"data" => list}) do
    Enum.reduce(list, %{}, fn market, acc ->
      #TODO: make it a struct
      past = %{
          "past_close" => market["adj_close"],
          "past_date" => market["date"]
        }

        Map.put(acc, market["symbol"], past)
    end)
  end

  defp build_current_data(past_data, %{"data" => current_data_list}) do
    Enum.reduce(past_data, %{}, fn {k, v}, acc ->
      current_data = Enum.find(current_data_list, &(&1["symbol"] == k))
      updated =
        v
        |> Map.put("current_close", current_data["adj_close"])
        |> Map.put("current_date", current_data["date"])

      Map.put(acc, k, updated)
    end)
  end



  defp request(symbols, past_date) do
    symbols
    |> build_url()
    |> build_past_date(past_date)
    |> Http.get()

    #{:ok, %{body: mock_past()}}

  end

  defp request(symbols) do
    symbols
    |> build_url()
    |> Http.get()

    # {:ok, %{body: mock_current()}}
  end

  defp build_url(symbols) do
    "http://api.marketstack.com/v1/eod"
    |> build_api_key(@api_key)
    |> add_limit(symbols)
    |> build_symbols(symbols)
  end


  defp build_api_key(url, key), do: url <> "?access_key=#{key}"
  defp build_past_date(url, date), do: url <> "&date_to=#{date}"

  defp build_symbols(url, symbols) do
    string_symbols = do_build_symbols(symbols, "")
    url <> "&symbols=#{string_symbols}"
  end

  defp add_limit(url, symbols) do
    # We assume the API response come in chunks
    limit = Enum.count(symbols)
    url <> "&limit=#{limit}"
  end

  defp do_build_symbols([hd | []], acc), do: acc <> hd

  defp do_build_symbols([hd | tl], acc) do
    do_build_symbols(tl, acc <> hd <> ",")
  end


  #TODO: temporary so I don't burn through the free quota
  defp mock_past do
"{\"pagination\":{\"limit\":2,\"offset\":0,\"count\":2,\"total\":238},\"data\":[{\"open\":395.96,\"high\":396.99,\"low\":385.96,\"close\":390.9,\"volume\":38306874.0,\"adj_high\":98.893919424,\"adj_low\":96.1462433333,\"adj_close\":97.3768435044,\"adj_open\":98.6373367972,\"adj_volume\":153227496.0,\"symbol\":\"AAPL\",\"exchange\":\"XNAS\",\"date\":\"2020-07-15T00:00:00+0000\"},{\"open\":1523.13,\"high\":1535.33,\"low\":1498.0,\"close\":1513.64,\"volume\":1761000.0,\"adj_high\":1535.33,\"adj_low\":1498.0,\"adj_close\":1513.64,\"adj_open\":1523.13,\"adj_volume\":1761000.0,\"symbol\":\"GOOG\",\"exchange\":\"XNAS\",\"date\":\"2020-07-15T00:00:00+0000\"}]}"
  end

  #TODO: temporary so I don't burn through the free quota
  defp mock_current do
"{\"pagination\":{\"limit\":2,\"offset\":0,\"count\":2,\"total\":504},\"data\":[{\"open\":1920.67,\"high\":1929.58,\"low\":1867.53,\"close\":1899.4,\"volume\":1925807.0,\"adj_high\":1929.58,\"adj_low\":1867.53,\"adj_close\":1899.4,\"adj_open\":1920.67,\"adj_volume\":1925807.0,\"symbol\":\"GOOG\",\"exchange\":\"XNAS\",\"date\":\"2021-01-25T00:00:00+0000\"},{\"open\":143.07,\"high\":145.09,\"low\":136.54,\"close\":142.92,\"volume\":157611713.0,\"adj_high\":145.09,\"adj_low\":136.54,\"adj_close\":142.92,\"adj_open\":143.07,\"adj_volume\":157611713.0,\"symbol\":\"AAPL\",\"exchange\":\"XNAS\",\"date\":\"2021-01-25T00:00:00+0000\"}]}"
  end
end
