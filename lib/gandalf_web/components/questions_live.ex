defmodule GandalfWeb.QuestionsLive do
  use Phoenix.LiveView
  alias Gandalf.Session
  import GandalfWeb.CoreComponents

  def render(socket = %{session: session}) do
    case Session.next_question(session) do
      {:ok, question} -> socket |> assign(:question, question) |> render_question()
      :finished -> socket |> assign(:conclusion, Session.conclude(session)) |> render_result()
    end
  end

  defp render_question(assigns) do
    ~H"""
    <div class="question place-items-center w-full">
      <p class="question-text mb-10 px-20">
        <%= @question.question_body %>
      </p>
      <%= for {answer, index} <- @question.answer_choices |> Enum.with_index() do %>
        <.button
          phx-click="answer"
          class="answer-button mb-3"
          phx-value-question-id="networks:1:1124"
          {["phx-value-answer-id": index]}
        >
          <%= answer %>
        </.button>
      <% end %>
    </div>
    """
  end

  defp render_result(assigns) do
    ~H"""
    <div class="question">
      <%= @conclusion %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, :session, Session.new())

    {:ok, socket}
  end

  def handle_event(
        "answer",
        val = %{"answer-id" => answer},
        socket = %{assigns: %{session: session}}
      ) do
    answer = String.to_integer(answer)
    IO.inspect(answer)
    {_, session} = Session.submit_answer(session, answer)
    {:noreply, assign(socket, :session, session)}
  end
end
