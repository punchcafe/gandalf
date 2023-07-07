defmodule Gandalf.Topic.Repo do
  @moduledoc ~S"""
  Module for accessing Topics.
  """

  alias Gandalf.Topic
  import Gandalf.YmlHelper

  @doc ~S"""
  Returns a list of all topics.
  """
  @spec all_topics() :: [Topic.t()]
  def all_topics() do
    "./resources/questions/"
    |> read_all()
    |> Enum.map(fn %{"topic" => topic} -> topic end)
    |> Enum.uniq()
  end

  @doc ~S"""
  Returns a list of all subtopics for a given topic.
  """
  @spec subtopics(Topic.t()) :: [Topic.t()]
  def subtopics(topic) do
    Enum.filter(all_topics(), &Topic.subtopic_of?(&1, topic))
  end
end
