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

      assert String.contains?(File.read!("comment.md"), [
               "## :red_circle:",
               "static analysis for security vulnerabilities",
               "code code code for SQL.Stream",
               "code code code for SQL injection"
             ])

      assert String.contains?(File.read!("comment.md"), "code code code for Config.CSP") == false
    end

    test "can create a comment correctly when there are no findings" do
      setup_stub(@http_client)

      File.cp!(
        Path.join(File.cwd!(), "test/empty.json"),
        Path.join(File.cwd!(), "sobelow.results.json")
      )

      assert :ok = Guide.run(source: "random-url.io/markdown.md", repo: "my-repo", commit: "hash")

      assert File.exists?("comment.md")

      assert String.contains?(File.read!("comment.md"), [
               "code code code for SQL.Stream",
               "code code code for SQL injection"
             ]) == false

      assert String.contains?(File.read!("comment.md"), [
               "## :green_circle:",
               "static analysis for security vulnerabilities",
               "No volunerabilities detected"
             ])
    end
  end
end
