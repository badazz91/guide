defmodule Mix.Tasks.GuideTest do
  @moduledoc false
  use ExUnit.Case
  use Guide.StubCase

  import ExUnit.CaptureIO

  alias Mix.Tasks.Guide, as: Task

  setup do
    reset_stage()

    on_exit(&reset_stage/0)

    :ok
  end

  defp output(filename),
    do: "Successfully prepared markdown:\n#{Path.join(File.cwd!(), filename)}\n"

  describe "mix task" do
    test "can run correctly with only the manditory options provided" do
      setup_stub(@http_client)

      assert capture_io(fn ->
               assert Task.run([
                        "--source",
                        "some-url.io/markdown.md",
                        "--repo",
                        "repo-name",
                        "--commit",
                        "hash"
                      ]) == 0
             end) == output("comment.md")
    end

    test "responds correctly when the url is not available" do
      setup_error_stub(@http_client)

      assert capture_io(fn ->
               assert Task.run([
                        "--source",
                        "some-url.io/markdown.md",
                        "--repo",
                        "repo-name",
                        "--commit",
                        "hash"
                      ]) == 1
             end) == "Error. Could not prepare markdown.\n"
    end

    test "raises errors if the manditory options are not provided" do
      assert_raise RuntimeError, "You must pass the commit hash via --commit.", fn ->
        Task.run(["--source", "some-url.io/markdown.md", "--repo", "repo-name"])
      end

      assert_raise RuntimeError, "You must pass the name of the repository via --repo.", fn ->
        Task.run(["--source", "some-url.io/markdown.md", "--commit", "commit-hash"])
      end

      assert_raise RuntimeError, fn ->
        Task.run([])
      end

      File.rm("sobelow.results.json")

      assert_raise RuntimeError, ~r/^Make sure to run sobelow first:/, fn ->
        Task.run([
          "--source",
          "some-url.io/markdown.md",
          "--repo",
          "repo-name",
          "--commit",
          "commit-hash"
        ])
      end
    end

    test "can run correctly with with a different source provided" do
      setup_stub(@http_client)

      assert capture_io(fn ->
               assert Task.run([
                        "--repo",
                        "repo-name",
                        "--commit",
                        "hash",
                        "--source",
                        "random-url.io/markdown.md"
                      ]) == 0
             end) == output("comment.md")
    end

    test "can run correctly with with a different target provided" do
      setup_stub(@http_client)

      assert capture_io(fn ->
               assert Task.run([
                        "--source",
                        "some-url.io/markdown.md",
                        "--repo",
                        "repo-name",
                        "--commit",
                        "hash",
                        "--target",
                        "test-markdown.md"
                      ]) == 0
             end) == output("test-markdown.md")

      File.rm("test-markdown.md")
    end

    test "can run correctly with with a different sobelow results file provided" do
      setup_stub(@http_client)

      assert capture_io(fn ->
               assert Task.run([
                        "--source",
                        "some-url.io/markdown.md",
                        "--repo",
                        "repo-name",
                        "--commit",
                        "hash",
                        "--results",
                        "test/fixtures.json"
                      ]) == 0
             end) == output("comment.md")
    end
  end
end
