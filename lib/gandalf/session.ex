defmodule Gandalf.Session do
    @type session_configuration :: map()
    @type session :: String.t()
    @type question_id :: String.t()

    @spec new_session(session_configuration()) :: {:ok, session()} | {:error, atom()}
    @spec new_session!() :: session() | no_return()

    @spec current_question(session) :: {:ok, question_id()} | :finished | {:error, atom()}

    @spec submit_answer(session(), answer_index :: integer())
end