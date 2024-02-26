defmodule GandalfWeb.QuestionsLive do
  use Phoenix.LiveView
  alias Gandalf.Session
  alias Gandalf.Resource.Repo
  import GandalfWeb.CoreComponents

  def render(socket = %{session: session}) do
    case Session.current_stage(session) do
      :profile_selection ->
        render_profile_selection(socket)

      :answering_questions ->
        {:ok, question} = Session.next_question(session)
        socket |> assign(:question, question) |> render_question()

      :finished ->
        failed_topics = Session.Insight.failed_topics(session)
        resources = Repo.topic_resources(failed_topics)

        socket
        |> assign(:topics, failed_topics)
        |> assign(:resources, resources)
        |> render_result()
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

  defp render_profile_selection(assigns) do
    ~H"""
    <div class="question place-items-center w-full">
      <%= for profile <- Gandalf.Profile.all_profiles() do %>
        <.button
          phx-click="profile-selection"
          class="answer-button mb-3"
          {["phx-value-profile-selection-id": profile]}
        >
          <%= profile %>
        </.button>
      <% end %>
    </div>
    """
  end

  defp render_result(assigns) do
    ~H"""
    <div class="question">
      It looks like you could do with a bit of practice in the following topics: <%= @topics %>
      <div class="resources">
        <%= for {topic, resources} <- @resources do %>
          <div class="topic_resources">
            <h2> <%= topic %> </h2>
            <%= for resource <- resources do %>
              <div>
                <h4><a href={resource.link}><%= resource.name %></a> </h4>
                <p>
                  <%= resource.description %>
                </p>
              </div>
            <% end %>
          </div>
        <% end %> 
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    session =
      :gandalf
      |> Application.fetch_env!(Gandalf.Session.Config)
      |> Session.Config.new()
      |> Session.new()

    socket = assign(socket, :session, session)

    {:ok, socket}
  end

  def handle_event(
        "profile-selection",
        %{"profile-selection-id" => profile},
        socket = %{assigns: %{session: session}}
      ) do
    session = Session.load_profile(session, profile)
    {:noreply, assign(socket, :session, session)}
  end

  def handle_event(
        "answer",
        %{"answer-id" => answer},
        socket = %{assigns: %{session: session}}
      ) do
    answer = String.to_integer(answer)
    {_, session} = Session.submit_answer(session, answer)
    {:noreply, assign(socket, :session, session)}
  end
end
