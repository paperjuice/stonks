defmodule Stonks.Integration.Shared.Http do
  @moduledoc false

  @type success :: %{
          body: String.t(),
          status_code: integer()
        }

  @type error :: %{
          error: String.t()
        }

  @callback get(String.t()) :: {:ok, success()} | {:error, any()}

  def get(url) do
    case HTTPoison.get(url) do
      {:ok,
       %HTTPoison.Response{
         body: body,
         status_code: code
       }} ->
        {:ok, %{body: body, status_code: code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{reason: reason}}
    end
  end
end
