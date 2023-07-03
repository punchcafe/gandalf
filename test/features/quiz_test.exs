defmodule MyApp.Features.QuizTest do
  use ExUnit.Case, async: false

  alias Gandalf.Session

  @questions_per_topic 3

  setup do
    config =
      Session.Config.new(
        failure_threshold: 0.6,
        max_topic_suggestions: 1,
        questions_per_topic: @questions_per_topic
      )

    %{session: Session.new(config)}
  end

  test "Test max_topic_suggestions", %{session: session} do
    result = {_, session} = answer_incorrectly(session, @questions_per_topic)
    assert_test_over(result)
    assert_suggested_topics(session, "networks")
  end

  defp answer_incorrectly(session, number_of_times \\ 1) do
    session =
      Enum.reduce(1..number_of_times, {:ok, session}, fn _, {_, session} ->
        Session.submit_answer(session, next_incorrect_answer(session))
      end)
  end

  defp next_correct_answer(session) do
    next_question_index = Enum.count(session.answers)
    next_question = Enum.at(session.questions, next_question_index)
    next_question.correct_answer_index
  end

  defp next_incorrect_answer(session) do
    session
    |> next_correct_answer()
    |> Kernel.+(1)
    |> rem(4)
  end

  def assert_test_over(result) do
    assert {:finished, _} = result
  end

  def assert_suggested_topics(session, topics) when is_list(topics) do
    topics = Enum.join(topics, ", ")
    assert Session.conclude(session) == "You need to practice #{topics}."
  end

  def assert_suggested_topics(session, topic), do: assert_suggested_topics(session, [topic])
end
