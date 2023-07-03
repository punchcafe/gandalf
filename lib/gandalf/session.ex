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

  def new(config = %Config{}) do
    initial_questions =
      1
      |> Repo.all()
      |> shuffle_and_take(Config.questions_per_topic(config))

    %__MODULE__{answers: [], questions: initial_questions, config: config}
  end

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
           answers: answers,
           config: config
         }
       ) do
    last_depth = Insight.last_question_depth(session)

    success_topics =
      session
      |> Insight.successful_topics()
      |> Enum.filter(&(Topic.depth(&1) == last_depth))

    with [_ | _] <- success_topics,
         all_next_questions = [_ | _] <- Repo.all(last_depth + 1, include: success_topics) do
      next_questions = shuffle_and_take(all_next_questions, Config.questions_per_topic(config))
      {:ok, %__MODULE__{session | questions: questions ++ next_questions}}
    else
      _ -> {:finished, session}
    end
  end

  defp shuffle_and_take(questions, questions_per_topic) do
    questions
    |> Enum.group_by(& &1.topic)
    |> Enum.flat_map(fn {_topic, questions} ->
      questions
      |> Enum.shuffle()
      |> Enum.take(questions_per_topic)
    end)
  end

  def submit_answer!(struct, answer_index) do
    case submit_answer(struct, answer_index) do
      {:ok, struct} -> struct
      {:finished, struct} -> struct
    end
  end

  def conclude(session) do
    "You need to practice #{session |> Insight.failed_topics() |> Enum.join(" ")}."
  end
end
