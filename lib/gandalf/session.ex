defmodule Gandalf.Session do
  alias Gandalf.Question.Repo
  alias Gandalf.Topic.Repo, as: TopicRepo
  alias Gandalf.Topic
  alias __MODULE__.Insight
  # @type session_configuration :: map()
  # @type session :: String.t()
  # @type question_id :: String.t()

  # @spec new_session(session_configuration()) :: {:ok, session()} | {:error, atom()}
  # @spec new_session!() :: session() | no_return()

  # @spec current_question(session) :: {:ok, question_id()} | :finished | {:error, atom()}

  # @spec submit_answer(session(), answer_index :: integer()) :: :ok | {:error, atom()}

  @type question :: %{
          question_body: String.t(),
          answer_choices: [String.t()],
          correct_answer_index: integer()
        }
  defstruct [:answers, :questions, :failed_topics]

  def new(), do: %__MODULE__{answers: [], questions: Repo.all(1), failed_topics: []}

  def next_question(%__MODULE__{
        answers: answers,
        questions: questions
      }) do
    next_answer_index = Enum.count(answers)

    # TODO, make raise?
    # Maybe make this function get current_question, so that it's always tied to a submit answer

    if next_answer_index < Enum.count(questions) do
      {:ok, Enum.at(questions, Enum.count(answers))}
    else
      :finished
    end
  end

  def submit_answer(session = %__MODULE__{answers: answers}, answer_index) do
    if Enum.count(answers) < Enum.count(session.questions) do
      updated_session = %__MODULE__{session | answers: answers ++ [answer_index]}

      if Enum.count(updated_session.answers) == Enum.count(session.questions) do
        load_next_or_finish(updated_session)
      else
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
           failed_topics: failed_topics_acc
         }
       ) do
    last_depth = Insight.last_question_depth(session)

    {success_topics, failed_topics} =
      session
      |> Insight.last_depth_insight()
      |> Insight.partition_insight()

    session = %__MODULE__{session | failed_topics: failed_topics ++ failed_topics_acc}
    topics_to_include = Enum.flat_map(success_topics, &TopicRepo.subtopics/1)

    with [_ | _] <- topics_to_include,
         next_questions = [_ | _] <- Repo.all(last_depth + 1, include: topics_to_include) do
      {:ok, %__MODULE__{session | questions: questions ++ next_questions}}
    else
      _ -> {:finished, session}
    end
  end

  defp load_questions(session, depth, excluding \\ []) do
    Repo.all(depth, excliuding: excluding)
  end

  def submit_answer!(struct, answer_index) do
    {:ok, struct} = submit_answer(struct, answer_index)
    struct
  end

  def conclude(%__MODULE__{failed_topics: failed_topics}) do
    "You need to practice #{Enum.join(failed_topics, " ")}."
  end

  defp get_score([], [], total), do: total

  defp get_score([%{correct_answer_index: index} | questions], [answer | answers], total) do
    total = total + if index == answer, do: 1, else: 0
    get_score(questions, answers, total)
  end
end
