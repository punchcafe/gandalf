defmodule Gandalf.Session do
  alias Gandalf.Question.Repo
  alias Gandalf.Topic
  alias __MODULE__.{Insight, Config}

  @type question :: %{
          question_body: String.t(),
          answer_choices: [String.t()],
          correct_answer_index: integer()
        }

  @type t :: struct()
  defstruct [:answers, :questions, :config]

  def new(config = %Config{}) do
    %__MODULE__{answers: [], questions: [], config: config}
  end

  @doc ~S"""
    Returns the current stage of the quiz the user is in.

    Possible stages are:
      - profile_selection: the user still has to select which profile they are quizzing as
      - answering_questions: the user is in the process of answering questions
      - finished: the user has finished the quiz
  """
  @spec current_stage(__MODULE__.t()) :: :profile_selection | :answering_questions | :finished
  def current_stage(session) do
    with {:profile_set, true} <- {:profile_set, profile_set?(session)},
         {:failed, false} <- {:failed, failed_topics_limit?(session)},
         {:ok, question} <-
           next_question(session) do
      :answering_questions
    else
      {:profile_set, false} ->
        :profile_selection

      _ ->
        :finished
    end
  end

  def load_profile(session = %__MODULE__{config: config}, profile) do
    included_topics = Gandalf.Profile.included_topics!(profile)

    initial_questions =
      1
      |> Repo.all(include: included_topics)
      |> shuffle_and_take(Config.questions_per_topic(config))
      |> sort_by_included_topics(included_topics)

    %__MODULE__{
      session
      | config: Config.set_included_topics(config, included_topics),
        questions: initial_questions
    }
  end

  def profile_set?(%__MODULE__{config: config}) do
    not is_nil(Config.included_topics(config) && Config.included_topics(config) != [])
  end

  def next_question(%__MODULE__{
        answers: answers,
        questions: questions
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
        failed_topics_limit?(updated_session) ->
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

  defp failed_topics_limit?(session) do
    session
    |> Insight.failed_topics()
    |> Enum.count() >= Config.max_topic_suggestions(session.config)
  end

  defp sort_by_included_topics(questions, included_topics) do
    topic_index_map =
      included_topics
      |> Enum.with_index()
      |> Enum.into(%{})

    question_comparator = fn question_a, question_b ->
      topic_index_map[question_a.topic] <= topic_index_map[question_b.topic]
    end

    Enum.sort(questions, question_comparator)
  end

  defp load_next_or_finish(
         session = %__MODULE__{
           questions: questions,
           config: config
         }
       ) do
    last_depth = Insight.last_question_depth(session)

    failed_topics =
      session
      |> Insight.failed_topics()
      |> Enum.filter(&(Topic.depth(&1) == last_depth))

    with all_next_questions = [_ | _] <-
           Repo.all(last_depth + 1,
             exclude: failed_topics,
             include: Config.included_topics(config)
           ) do
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
end
