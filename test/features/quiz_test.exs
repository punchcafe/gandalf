defmodule MyApp.Features.QuizTest do
  use Cabbage.Feature, async: false, file: "quiz.feature"

  alias Gandalf.Session

  defgiven ~r/^failure threshold is (?<failure_threshold>[^ ]+), questions per topic is (?<questions_per_topic>\d+), and max reccomendations is (?<max_topic_suggestions>\d+)/,
           %{
             failure_threshold: ft,
             max_topic_suggestions: mts,
             questions_per_topic: qpt
           },
           state do
    ft = String.to_float(ft)
    mts = String.to_integer(mts)
    qpt = String.to_integer(qpt)

    session =
      [failure_threshold: ft, max_topic_suggestions: mts, questions_per_topic: qpt]
      |> Session.Config.new()
      |> Session.new()

    {:ok, Map.put(state, :session, session)}
  end

  defgiven ~r/^I have answered (?<incorrect_answers>[\d]+) incorrectly$/,
           %{incorrect_answers: incorrect_answers},
           %{
             session: session
           } do
    incorrect_answers = String.to_integer(incorrect_answers)

    session =
      Enum.reduce(1..incorrect_answers, session, fn _, session ->
        Session.submit_answer!(session, next_incorrect_answer(session))
      end)

    {:ok, %{session: session}}
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

  defwhen ~r/^I answer incorrectly$/, _, state = %{session: session} do
    result = Session.submit_answer(session, next_incorrect_answer(session))
    state = Map.put(state, :result, result)

    case result do
      {_, session = %Session{}} -> {:ok, Map.put(state, :session, session)}
      _ -> {:ok, state}
    end
  end

  defthen ~r/^The test should be over$/, _, %{result: result} do
    assert {:finished, _} = result
  end

  defthen ~r/^I should be suggested networks$/, _, %{session: session} do
    assert Session.conclude(session) == "You need to practice networks."
  end
end
