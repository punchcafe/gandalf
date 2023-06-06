defmodule GandalfWeb.QuestionsLive do
  use Phoenix.LiveView
  alias Gandalf.Session

  def render(socket = %{session: session}) do
    case Session.next_question(session) do
      {:ok, question} -> socket |> assign(:question, question) |> render_question()
      {:error, _} -> socket |> assign(:conclusion, Session.conclude(session)) |> render_result()
    end
  end

  defp render_question(assigns) do
    ~H"""
    <div class="question">
      <p class="question-text">
        <%= @question.question_body %>
      </p>
      <%= for {answer, index} <- @question.answer_choices |> Enum.with_index() do %>
        <button phx-click="answer" phx-value-question-id="networks:1:1124" {["phx-value-answer-id": index]}>
          <%= answer %>
        </button>
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

  def handle_event("answer", val= %{"answer-id" => answer}, socket = %{assigns: %{session: session}}) do
    answer = String.to_integer(answer)
    IO.inspect(answer)
    {:ok, session} = Session.submit_answer(session, answer)
    {:noreply, assign(socket, :session, session)}
  end

end
