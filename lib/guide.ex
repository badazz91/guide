defmodule Guide do
  @moduledoc """
  Turns sobelow static code analysis results into markdown, by:

  1. Fetching a collection of recommendations in markdown,
  2. Extracting the needed parts out of (1), that match the sobelow findings,
  3. Prepare markdown that can be used to decorate PRs in GitHub.
  """
  @pattern ~r/## UID (.*?)/

  alias Guide.Api
  alias Guide.Templates

  @doc """
  Writes the finished markdown to a file.

  Returns :ok or {:error, _reason}.
  """
  def run(opts \\ []) do
    HTTPoison.start()
    source = Keyword.get(opts, :source)
    results = Keyword.get(opts, :results, "sobelow.results.json")
    target = Keyword.get(opts, :target, "comment.md")

    case Api.get(source) do
      {:ok, body} ->
        all_findings = get_all(results)

        guides =
          all_findings
          |> Enum.map(&extract(body, &1))
          |> Enum.uniq()

        markdown(opts, guides, all_findings) |> write(target)

      _ ->
        {:error, "Could not load source url."}
    end
  end

  defp extract(markdown, %{"type" => type}) do
    guide =
      markdown
      |> Earmark.Restructure.split_by_regex(@pattern, fn [_, inner | _] -> inner end)
      |> Enum.reject(fn blob -> blob == "" end)
      |> Kernel.tl()
      |> Enum.find(fn blob -> String.contains?(blob, type) end)

    {type, EEx.eval_string(Templates.section(), snippet: guide)}
  end

  defp code_snippet(opts, %{"file" => file, "line" => 0}) do
    repo = Keyword.get(opts, :repo)
    commit = Keyword.get(opts, :commit)
    "https://github.com/#{repo}/blob/#{commit}/#{file}"
  end

  defp code_snippet(opts, %{"file" => file, "line" => line}) do
    repo = Keyword.get(opts, :repo)
    commit = Keyword.get(opts, :commit)
    "https://github.com/#{repo}/blob/#{commit}/#{file}#L#{line}"
  end

  defp write(markdown, file), do: File.write(file, markdown)

  defp get_all(path) do
    %{"high_confidence" => highs, "medium_confidence" => mids, "low_confidence" => lows} =
      File.read!(path)
      |> Jason.decode!()
      |> Map.get("findings")

    highs ++ mids ++ lows
  end

  defp markdown(opts, guides, findings) do
    case Kernel.length(findings) do
      0 ->
        EEx.eval_string(Templates.empty())

      _ ->
        guides
        |> Enum.map_join("\n\n", &make_section(&1, opts, findings))
        |> String.trim()
    end
  end

  defp make_section({type, md}, opts, findings) do
    snippets =
      findings
      |> Enum.filter(fn %{"type" => t} -> t == type end)
      |> Enum.map_join("\n\n", &code_snippet(opts, &1))

    md
    |> Kernel.<>("\n\n### Findings: \n")
    |> Kernel.<>(snippets)
  end
end
