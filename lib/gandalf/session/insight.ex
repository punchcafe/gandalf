defmodule Gandalf.Session.Insight do
  alias Gandalf.Topic
  alias Gandalf.Session

  def last_depth_insight(%Session{questions: questions, answers: answers}) do
    last_depth = questions |> List.last() |> Map.get(:topic) |> Topic.depth()

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

  defp average_correct_answers(answers) do
    total_correct = answers |> Enum.filter(& &1) |> Enum.count()
    total_correct / Enum.count(answers)
  end
end
