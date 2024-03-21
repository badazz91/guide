defmodule Guide.Templates do
  @moduledoc """
  Provide markdown templates for rendering.
  """

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
  Template for when no vulnerabilities where found.
  """
  def empty do
    """
    ## :green_circle: static analysis for security vulnerabilities

    No volunerabilities detected :white_check_mark:
    """
  end
end
