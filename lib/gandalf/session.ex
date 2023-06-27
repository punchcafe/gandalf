defmodule Gandalf.Session do
  alias Gandalf.Question.Repo
  alias Gandalf.Topic.Repo, as: TopicRepo
  alias Gandalf.Topic
  alias __MODULE__.{Insight, Config}

  @type question :: %{
          question_body: String.t(),
          answer_choices: [String.t()],
          correct_answer_index: integer()
        }
  defstruct [:answers, :questions, :config]

  def new(config = %Config{}),
    do: %__MODULE__{answers: [], questions: Repo.all(1), config: config}

  def next_question(%__MODULE__{
        answers: answers,
        questions: questions,
        config: config
      }) do
    next_answer_index = Enum.count(answers)

    if next_answer_index < Enum.count(questions) do
      {:ok, Enum.at(questions, Enum.count(answers))}
    else
      :finished
    end
  end

  def submit_answer(session = %__MODULE__{answers: answers, config: config}, answer_index) do
    if Enum.count(answers) < Enum.count(session.questions) do
      updated_session = %__MODULE__{session | answers: answers ++ [answer_index]}

      cond do
        updated_session |> Insight.failed_topics() |> Enum.count() >=
            Config.max_topic_suggestions(config) ->
          {:finished, updated_session}

        Enum.count(updated_session.answers) == Enum.count(session.questions) ->
          load_next_or_finish(updated_session)

        :continue ->
          {:ok, updated_session}
      end
    else
      {:finished, session}
    end
  end

  defp load_next_or_finish(
         session = %__MODULE__{
           questions: questions,
           answers: answers
         }
       ) do
    last_depth = Insight.last_question_depth(session)

    success_topics =
      session
      |> Insight.successful_topics()
      |> Enum.filter(&(Topic.depth(&1) == last_depth))

    with [_ | _] <- success_topics,
         next_questions = [_ | _] <- Repo.all(last_depth + 1, include: success_topics) do
      {:ok, %__MODULE__{session | questions: questions ++ next_questions}}
    else
      _ -> {:finished, session}
    end
  end

  def submit_answer!(struct, answer_index) do
    {:ok, struct} = submit_answer(struct, answer_index)
    struct
  end

  def conclude(session) do
    "You need to practice #{session |> Insight.failed_topics() |> Enum.join(" ")}."
  end
end
