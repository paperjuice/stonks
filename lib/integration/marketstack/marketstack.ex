defmodule Stonks.Integration.Marketstack do
  @moduledoc false

  @http Application.compile_env(:stonks, :http_client)

  @type symbol :: String.t()
  @type current_close :: String.t()
  @type current_date :: String.t()
  @type past_close :: String.t()
  @type past_date :: String.t()

  @type t :: %{
          symbol() => %{
            current_close() => float(),
            current_date() => String.t(),
            past_close() => float(),
            past_date() => String.t()
          }
        }

  @spec get_markets(list(String.t()), String.t()) :: {:error, String.t()} | {:ok, list(t())}
  def get_markets(symbols, past_date) do
    async_requests(symbols, past_date)
  end

  #  The purpose of this function is to send 2 requests to marketstack async
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

    # TODO: Required response data validation
    # Order is guaranteed
    with {:ok, past_stocks} <- handle_response(past_result),
         {:ok, current_stocks} <- handle_response(current_result),
         {:ok, data} <- build_past_data(past_stocks) do
      {:ok, build_current_data(data, current_stocks)}
    end
  end

  defp handle_response(nil), do: {:error, :timeout}

  defp handle_response({:ok, {:ok, %{body: body}}}) do
    Poison.decode(body)
  end

  # I use adj_close instead of close because I saw big discrepancies between `close`
  # and all the other values
  defp build_past_data(%{"data" => list}) do
    past_data =
      Enum.reduce(list, %{}, fn market, acc ->
        # TODO: make it a struct
        past = %{
          "past_close" => market["adj_close"],
          "past_date" => market["date"]
        }

        Map.put(acc, market["symbol"], past)
      end)

    {:ok, past_data}
  end

  defp build_past_data(%{"error" => %{"code" => code, "message" => _msg}}) do
    {:error, code}
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
    |> @http.get()
  end

  defp request(symbols) do
    symbols
    |> build_url()
    |> @http.get()
  end

  defp build_url(symbols) do
    api_key = get_api_key()

    "http://api.marketstack.com/v1/eod"
    |> build_api_key(api_key)
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

  defp get_api_key,
    do: Application.get_env(:stonks, :marketstack_api_key)
end
