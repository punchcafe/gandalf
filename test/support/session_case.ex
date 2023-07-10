defmodule Gandalf.SessionCase do
  use ExUnit.CaseTemplate
  alias Gandalf.Session

  using do
    quote do
      import Gandalf.SessionCase
    end
  end

  def answer_incorrectly(session, number_of_times \\ 1) do
    Enum.reduce(1..number_of_times, {:ok, session}, fn _, {_, session} ->
      Session.submit_answer(session, next_incorrect_answer(session))
    end)
  end

  def answer_correctly(session, number_of_times \\ 1) do
    Enum.reduce(1..number_of_times, {:ok, session}, fn _, {_, session} ->
      Session.submit_answer(session, next_correct_answer(session))
    end)
  end

  def next_correct_answer(session) do
    next_question_index = Enum.count(session.answers)
    next_question = Enum.at(session.questions, next_question_index)
    next_question.correct_answer_index
  end

  def next_incorrect_answer(session) do
    session
    |> next_correct_answer()
    |> Kernel.+(1)
    |> rem(4)
  end

  def assert_test_over(result) do
    assert {:finished, _} = result
  end

  def assert_suggested_topics(session, topics) when is_list(topics) do
    assert Session.Insight.failed_topics(session) == topics
  end

  def assert_suggested_topics(session, topic), do: assert_suggested_topics(session, [topic])
end
