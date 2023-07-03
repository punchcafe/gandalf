defmodule MyApp.Features.QuizTest do
  use ExUnit.Case, async: false

  alias Gandalf.Session

  @questions_per_topic 3
  @top_level_topics 3
  @number_of_sub_topics 3

  setup do
    config =
      Session.Config.new(
        failure_threshold: 0.6,
        max_topic_suggestions: 1,
        questions_per_topic: @questions_per_topic
      )

    %{session: Session.new(config)}
  end

  test "Returns top level suggestion", %{session: session} do
    result = {_, session} = answer_incorrectly(session, @questions_per_topic)
    assert_test_over(result)
    assert_suggested_topics(session, "data_structures")
  end

  test "Doesn't return topic if passed, and skips sub topics if other top level topic failed", %{
    session: session
  } do
    {:ok, session} = answer_correctly(session, @questions_per_topic)
    result = {_, session} = answer_incorrectly(session, @questions_per_topic)

    assert_test_over(result)
    assert_suggested_topics(session, "databases")
  end

  test "Returns a subtopic suggestion", %{session: session} do
    {:ok, session} = answer_correctly(session, @questions_per_topic * @top_level_topics)
    result = {_, session} = answer_incorrectly(session, @questions_per_topic)

    assert_test_over(result)
    assert_suggested_topics(session, "databases:rds")
  end

  test "returns a mix of top level and sub level suggestions", %{session: session} do
    session = %{session | config: %{session.config | max_topic_suggestions: 2}}

    result = {_, session} = answer_incorrectly(session, @questions_per_topic)

    result =
      {_, session} = answer_correctly(session, @questions_per_topic * (@top_level_topics - 1))

    result = {_, session} = answer_incorrectly(session, @questions_per_topic)

    assert_test_over(result)
    assert_suggested_topics(session, ["data_structures", "databases:rds"])
  end

  test "test is over when questions run out, and returns no suggestions", %{session: session} do
    result =
      {_, session} =
      answer_correctly(
        session,
        @questions_per_topic * (@top_level_topics + @number_of_sub_topics)
      )

    assert_test_over(result)
    assert_suggested_topics(session, [])
  end

  defp answer_incorrectly(session, number_of_times \\ 1) do
    session =
      Enum.reduce(1..number_of_times, {:ok, session}, fn _, {_, session} ->
        Session.submit_answer(session, next_incorrect_answer(session))
      end)
  end

  defp answer_correctly(session, number_of_times \\ 1) do
    session =
      Enum.reduce(1..number_of_times, {:ok, session}, fn _, {_, session} ->
        Session.submit_answer(session, next_correct_answer(session))
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
    topics = Enum.join(topics, " ")
    assert Session.conclude(session) == "You need to practice #{topics}."
  end

  def assert_suggested_topics(session, topic), do: assert_suggested_topics(session, [topic])
end
