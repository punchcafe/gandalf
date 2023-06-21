defmodule Gandalf.Question do
  @type question :: %{
          question_body: String.t(),
          answer_choices: [String.t()],
          correct_answer_index: integer()
        }

  @type t :: %__MODULE__{
          topic: Topic.t(),
          question_body: String.t(),
          answer_choices: [String.t()],
          correct_answer_index: integer()
        }
  defstruct [:question_body, :answer_choices, :correct_answer_index, :topic]
end
