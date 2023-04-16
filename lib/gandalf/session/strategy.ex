defmodule Gandalf.Session.Strategy do
    # Strategies for calculating next question to ask

    @type session :: map() # Actuall session retrieved from session id

    @behaviour Gandalf.Session.Strategy
    @callback next_question(session | session_id) :: {:ok, question_id()} | :finished | {:error, atom()}
    @callback result(session) :: {:ok, result()}
end