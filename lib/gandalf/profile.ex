defmodule Gandalf.Profile do
  @moduledoc ~S"""
  Module for accessing and retrieving data on profile resources.
  """

  import Gandalf.YmlHelper

  @doc ~S"""
  Returns a string list of all available profiles.
  """
  @spec all_profiles() :: [String.t()]
  def all_profiles() do
    "./profiles/"
    |> read_all()
    |> Enum.map(fn %{"name" => name} -> name end)
    |> Enum.uniq()
  end

  @doc ~S"""
  Retrieve the included topics list for a given profile.
  """
  @spec included_topics!(String.t()) :: [String.t()]
  def included_topics!(profile) do
    "./profiles/"
    |> read_all()
    |> Enum.find(fn %{"name" => name} -> name == profile end)
    |> then(fn %{"included_topics" => topics} -> topics end)
  end
end
