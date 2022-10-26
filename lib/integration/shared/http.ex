defmodule Stonks.Integration.Shared.Http do
  @moduledoc false

  @type success :: %{
          body: String.t(),
          status_code: integer()
        }

  @type error :: %{
          error: String.t()
        }

  # I set up a contract here in order to be able to test using Mox
  # An improved approach is to split this module into two: one
  # with the API containing the callback deficlarations and
  # another with the implementations. That way we don't have to
  # use attributes to call the right module e.g. marketstack.ex / @http
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
