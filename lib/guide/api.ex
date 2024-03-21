defmodule Guide.Api do
  @moduledoc """
  Provides abstraction to load data from a remote url.
  """
  @doc """
  Fetch the markdown data.
  """
  def get(url, config \\ default_config()) do
    http_client = Keyword.get(config, :http_client, HTTPoison)

    case http_client.get(url) do
      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok, body}

      _ ->
        {:error, "Could not load url."}
    end
  end

  defp default_config, do: Application.get_env(:guide, :api, [])
end
