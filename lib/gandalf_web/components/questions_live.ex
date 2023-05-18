defmodule GandalfWeb.QuestionsLive do

    use Phoenix.LiveView

    def render(assigns) do
        ~H"""
        <div class="question">
          <p class="question-text">
            <%= @question_text %>
          </p>
          <button phx-click="answer" phx-value-question-id="networks:1:1124" phx-value-answer-id="1">1</button>
          <button phx-click="answer" phx-value-question-id="networks:1:1124" phx-value-answer-id="2">2</button>
        </div>
        """
    end

    def mount(_params, _session, socket) do
        socket = assign(socket, :question_text, "What about second breakfast?")
        if connected?(socket) do
          Process.send_after(self(), :ping, 5_000)
        end
        {:ok, socket}
    end

    def handle_event("answer", value, socket) do
      new_text = "You clicked #{inspect(value)}. " <> socket.assigns[:question_text]
      {:noreply, assign(socket, :question_text, new_text)}
    end

    def handle_info(:ping, socket) do
      new_text = "What about second breakfast? " <> socket.assigns[:question_text]
      Process.send_after(self(), :ping, 5_000)
      {:noreply, assign(socket, :question_text, new_text)}
    end
end