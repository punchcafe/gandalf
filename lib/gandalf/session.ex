defmodule Gandalf.Session do
  # @type session_configuration :: map()
  # @type session :: String.t()
  # @type question_id :: String.t()

  # @spec new_session(session_configuration()) :: {:ok, session()} | {:error, atom()}
  # @spec new_session!() :: session() | no_return()

  # @spec current_question(session) :: {:ok, question_id()} | :finished | {:error, atom()}

  # @spec submit_answer(session(), answer_index :: integer()) :: :ok | {:error, atom()}

  @sample_questions [
    %{
      question_body: "what's two plus three?",
      answer_choices: ["1", "2", "3", "5"],
      correct_answer_index: 3
    },
    %{
      question_body: "what's three plus four?",
      answer_choices: ["7", "2", "3", "5"],
      correct_answer_index: 0
    },
    %{
      question_body: "what's one plus one?",
      answer_choices: ["1", "2", "3", "5"],
      correct_answer_index: 1
    }
  ]

  @type question :: %{
          question_body: String.t(),
          answer_choices: [String.t()],
          correct_answer_index: integer()
        }
  defstruct [:answers, :questions]

  def new(), do: %__MODULE__{answers: [], questions: @sample_questions}

  def next_question(%__MODULE__{
        answers: answers,
        questions: questions
      }) do
    next_answer_index = Enum.count(answers)
    if next_answer_index < Enum.count(questions) do
        {:ok, Enum.at(questions, Enum.count(answers))}
    else
        {:error, :quiz_finished}
    end
  end

  def submit_answer(session = %__MODULE__{answers: answers}, answer_index) do
    if Enum.count(answers) < Enum.count(session.questions) do
      {:ok, %__MODULE__{session | answers: answers ++ [answer_index]}}
    else
      {:error, :quiz_finished}
    end
  end

  def submit_answer!(struct, answer_index) do
    {:ok, struct} = submit_answer(struct, answer_index)
    struct
  end

  def conclude(%__MODULE__{answers: answers, questions: questions}) do
    total_questions = Enum.count(questions)
    score = get_score(questions, answers, 0)
    "You scored #{score} out #{total_questions}"
  end

  defp get_score([], [], total), do: total
  defp get_score([%{correct_answer_index: index} | questions ], [answer | answers], total) do
    total = total + if index == answer, do: 1, else: 0
    get_score(questions, answers, total)
  end
end
