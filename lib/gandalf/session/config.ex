defmodule Gandalf.Session.Config do
  @moduledoc ~S"""
  Configuration parameters for quiz sessions.
  """
  @opaque t :: struct()
  @enforce_keys [
    :questions_per_topic,
    :failure_threshold,
    :max_topic_suggestions
  ]

  @optional_keys [
    :included_topics
  ]
  defstruct @enforce_keys ++ @optional_keys

  @doc ~S"""
  Create a new configuration struct with the following options:
    questions_per_topic: the number of questions to ask for each topic or subtopic

    failure_threshold: A float value indicating the failure threshold for average score on a topic

    max_topic_suggestions: the maximum number of topics to suggest to a user to study at once. Once this
    number has been reached, the quiz will be completed and the topics presented to the user.
  """
  @spec new(opts :: Keyword.t()) :: __MODULE__.t()
  def new(opts) when is_list(opts) do
    if Enum.any?(opts, fn {key, v} -> key not in @enforce_keys end) do
      raise "Unknown opt provided. Valid opts are: #{Enum.join(@enforce_keys, ", ")}"
    end

    struct!(__MODULE__, opts)
  end

  def set_included_topics(session = %__MODULE__{}, included_topics) do
    %__MODULE__{session | included_topics: included_topics}
  end

  @spec max_topic_suggestions(__MODULE__.t()) :: integer()
  def max_topic_suggestions(%__MODULE__{max_topic_suggestions: mts}), do: mts

  @spec questions_per_topic(__MODULE__.t()) :: integer()
  def questions_per_topic(%__MODULE__{questions_per_topic: qpt}), do: qpt

  @spec failure_threshold(__MODULE__.t()) :: float()
  def failure_threshold(%__MODULE__{failure_threshold: failure_threshold}), do: failure_threshold

  @spec included_topics(__MODULE__.t()) :: [String.t()]
  def included_topics(%__MODULE__{included_topics: included_topics}), do: included_topics
end
