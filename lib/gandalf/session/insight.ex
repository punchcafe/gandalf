defmodule Gandalf.Session.Insight do
  @moduledoc ~S"""
  Module for deriving insights into the current quiz session.
  """

  alias Gandalf.Topic
  alias Gandalf.Session
  alias Gandalf.Session.Config

  @type insight :: %{Topic.t() => Float.t()}

  @doc ~S"""
  Returns the topic depth of the last question loaded in the session.
  This won't necessarily be the last question answered by the user.
  """
  @spec last_question_depth(Session.t()) :: Integer.t()
  def last_question_depth(%Session{questions: questions}) do
    questions
    |> List.last()
    |> Map.get(:topic)
    |> Topic.depth()
  end

  @doc ~S"""
  Returns a list of topics the user has failed. It will not return topics where the 
  user hasn't completed enough questions in that topic, even if the success ratio is low.
  """
  @spec failed_topics(Session.t()) :: [String.t()]
  def failed_topics(session) do
    session
    |> topic_success_ratios()
    |> Stream.filter(&failed_topic?(&1, session))
    |> Enum.map(&extract_topic/1)
  end

  @doc ~S"""
  Returns a list of topics the user has been successful. It will not return topics where the 
  user hasn't completed enough questions in that topic, even if the success ratio is high.
  """
  @spec successful_topics(Session.t()) :: [String.t()]
  def successful_topics(session) do
    session
    |> topic_success_ratios()
    |> Stream.reject(&failed_topic?(&1, session))
    |> Enum.map(&extract_topic/1)
  end

  defp topic_success_ratios(%Session{questions: questions, answers: answers, config: config}) do
    questions
    |> Stream.zip(answers)
    |> Stream.map(fn {%{topic: topic, correct_answer_index: correct_answer}, user_answer} ->
      {topic, correct_answer == user_answer}
    end)
    |> Enum.group_by(fn {topic, _} -> topic end, fn {_, correct?} -> correct? end)
    |> Stream.reject(fn {_, answers} ->
      Enum.count(answers) < Config.questions_per_topic(config)
    end)
    |> Stream.map(fn {topic, answers} -> {topic, average_correct_answers(answers)} end)
    |> Enum.into(%{})
  end

  defp average_correct_answers(answers) do
    total_correct = answers |> Enum.filter(& &1) |> Enum.count()
    total_correct / Enum.count(answers)
  end

  defp failed_topic?({_topic, success_ratio}, %{config: config}),
    do: success_ratio < Config.failure_threshold(config)

  defp extract_topic({topic, _}), do: topic
end
