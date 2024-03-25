defmodule Guide.Templates do
  @moduledoc """
  Provide markdown templates for rendering.
  """

  @title "static analysis for security vulnerabilities"

  @doc """
  Template for one section (one vulnerability).
  """
  def section do
    """
    ## :x: <%= snippet %>

    See https://github.com/paraxialio/sobelow_guide for more information.
    """
  end

  @doc """
  Template for when no vulnerabilities were found.
  """
  def empty do
    """
    ## :green_circle: #{@title}

    No volunerabilities detected :white_check_mark:
    """
  end

  @doc """
  Template for when vulnerabilities were found.
  """
  def findings do
    """
    ## :red_circle: #{@title}

    <%= sections %>
    """
  end
end
