defmodule Stonks.Integration.Marketstack.Async do
  @moduledoc """
  The purpose of this module is to send 2 requests to marketstack async
  From their documentation doesn't seem to exist a way to get a stock from the past and
  another one from present (list with to obj)
  """

  # TODO: This wont work when api_key is part of sys env var
  @api_key Application.get_env(:stonks, :marketstack_api_key)

  alias Stonks.Integration.Shared.Http

  use GenServer

  @a %{
    "id" => %{
      state: "SUCCESS",
      data: [
        %{
          "symbol" => "AAPL",
          "past_close" => 213.2,
          "current_close" => 218.2,
          "past_date" => "2019-01-01",
          "current_date" => "2021-01-26"
        },
        %{
          "symbol" => "GOOG",
          "past_close" => 183.2,
          "current_close" => 210.2,
          "past_date" => "2019-01-01",
          "current_date" => "2021-01-26"
        }
      ]
    }
  }

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  # TODO: rename
  def async_request(params) do
    GenServer.call(__MODULE__, {:request, params})
  end

  @impl true
  def handle_call({:request, params}, _from, state) do
    # TODO: make 2 aync req, 1 with past date, 2, without
    # on response, save the data in state
    # recursively wait for response or timeout

    req_id = UUID.uuid1()
    Process.spawn(fn -> request_with_past_date(id, params) end, [:link])
    # TODO: wait for the state to fill or timeout


    #TODO: clean state of the resp
    {:reply, "", state}
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp request_with_past_date(id, params) do
    url = build_url(params)

  end

  defp build_url_with_past_date(%{symbols: symbols, past_date: date}) do
    "http://api.marketstack.com/v1/eod"
    |> build_api_key(@api_key)
    |> build_past_date(date)
    |> build_symbols(symbols)
    |> add_limit(symbols)
  end

  defp build_url_with_current_date(%{symbols: symbols}) do
    "http://api.marketstack.com/v1/eod"
    |> build_api_key(@api_key)
    |> build_symbols(symbols)
    |> add_limit(symbols)
  end

  defp build_api_key(url, key), do: url <> "?access_key=#{key}"
  defp build_past_date(url, date), do: url <> "&date_to=#{date}"

  defp build_symbols(url, symbols) do
    string_symbols = do_build_symbols(symbols, "")
    url <> "&symbols=#{string_symbols}"
  end

  defp do_build_symbols([hd | []], acc), do: acc <> hd

  defp do_build_symbols([hd | tl], acc) do
    do_build_symbols(tl, acc <> hd <> ",")
  end

  defp add_limit(url, symbols) do
    # We assume the API response come in chunks
    limit = Enum.count(symbols)
    url <> "&limit=#{limit}"
  end
end
