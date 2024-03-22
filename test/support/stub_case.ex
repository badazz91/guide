defmodule Guide.StubCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      import Mox
      @http_client Guide.HTTPClientMock

      defp setup_stub(client) do
        response = %HTTPoison.Response{
          body: File.read!(Path.join(File.cwd!(), "test/fixtures.md")),
          status_code: 200
        }

        expect(client, :get, fn _ -> {:ok, response} end)
      end

      defp setup_error_stub(client) do
        response = %HTTPoison.Response{
          body: "{\"error\": \"error\"}",
          status_code: 400
        }

        expect(client, :get, fn _ -> {:error, response} end)
      end

      defp reset_stage do
        File.rm("comment.md")

        File.cp!(
          Path.join(File.cwd!(), "test/fixtures.json"),
          Path.join(File.cwd!(), "sobelow.results.json")
        )
      end
    end
  end
end
