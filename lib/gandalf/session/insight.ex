defmodule Gandalf.Session.Insight do
  @moduledoc ~S"""
  Module for deriving information and state from a session struct.
  """
  alias Gandalf.Topic
  alias Gandalf.Session

  @type insight :: %{Topic.t() => Float.t()}

  @failed_threshold 0.5

  def last_question_depth(%Session{questions: questions, answers: answers}) do
    questions |> List.last() |> Map.get(:topic) |> Topic.depth()
  end

  def last_depth_insight(session = %Session{questions: questions, answers: answers}) do
    last_depth = last_question_depth(session)

    questions
    |> Stream.zip(answers)
    # only analyze last depth
    |> Stream.filter(fn {%{topic: topic}, _} -> Topic.depth(topic) == last_depth end)
    |> Stream.map(fn {%{topic: topic, correct_answer_index: correct_answer}, user_answer} ->
      {topic, correct_answer == user_answer}
    end)
    |> Enum.group_by(fn {topic, _?} -> topic end, fn {_, correct?} -> correct? end)
    |> Enum.map(fn {topic, answers} -> {topic, average_correct_answers(answers)} end)
    |> Enum.into(%{})
  end

  def partition_insight(insight) do
    Enum.reduce(insight, {[], []}, fn {topic, average}, {succeded_topics, failed_topics} ->
      if average < @failed_threshold do
        {succeded_topics, [topic | failed_topics]}
      else
        {[topic | succeded_topics], failed_topics}
      end
    end)
  end

  defp average_correct_answers(answers) do
    total_correct = answers |> Enum.filter(& &1) |> Enum.count()
    total_correct / Enum.count(answers)
  end
end
