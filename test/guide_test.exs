defmodule GuideTest do
  @moduledoc false
  use ExUnit.Case
  use Guide.StubCase

  setup do
    reset_stage()

    on_exit(&reset_stage/0)

    :ok
  end

  describe "Guide" do
    test "can create a comment correctly when there are findings" do
      setup_stub(@http_client)

      assert :ok = Guide.run(source: "random-url.io/markdown.md", repo: "my-repo", commit: "hash")

      assert File.exists?("comment.md")

      md = File.read!("comment.md")

      assert String.contains?(md, "## :red_circle:")
      assert String.contains?(md, "static analysis for security vulnerabilities")
      assert String.contains?(md, "code code code for SQL.Stream")
      assert String.contains?(md, "code code code for SQL injection")

      assert String.contains?(md, "code code code for Config.CSP") == false
    end

    test "can create a comment correctly when there are no findings" do
      setup_stub(@http_client)

      File.cp!(
        Path.join(File.cwd!(), "test/fixtures/empty.json"),
        Path.join(File.cwd!(), "sobelow.results.json")
      )

      assert :ok = Guide.run(source: "random-url.io/markdown.md", repo: "my-repo", commit: "hash")

      assert File.exists?("comment.md")

      md = File.read!("comment.md")

      assert String.contains?(md, "code code code for SQL.Stream") == false

      assert String.contains?(md, "## :green_circle:")
      assert String.contains?(md, "static analysis for security vulnerabilities")
      assert String.contains?(md, "No volunerabilities detected")
    end

    test "can create a comment correctly when there are findings with special characters in the header" do
      setup_stub(@http_client)

      File.cp!(
        Path.join(File.cwd!(), "test/fixtures/type-non-exact-match.json"),
        Path.join(File.cwd!(), "sobelow.results.json")
      )

      assert :ok = Guide.run(source: "random-url.io/markdown.md", repo: "my-repo", commit: "hash")

      md = File.read!("comment.md")

      assert String.contains?(md, "## :red_circle:")
      assert String.contains?(md, "static analysis for security vulnerabilities")
      assert String.contains?(md, "Header with special `characters.non-exact-match`")
    end
  end
end
