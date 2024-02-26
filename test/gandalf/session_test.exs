defmodule Gandalf.SessionTest do
  use Gandalf.SessionCase, async: false

  alias Gandalf.Session

  @questions_per_topic 1
  @top_level_topics 3
  @number_of_sub_topics 3

  setup do
    config =
      Session.Config.new(
        failure_threshold: 0.6,
        max_topic_suggestions: 1,
        questions_per_topic: @questions_per_topic
      )

    %{session: Session.new(config)}
  end

  describe "current_stage/1" do
    test "returns profile selection for a new session", %{session: session} do
      assert Session.current_stage(session) == :profile_selection
    end

    test "returns :quiz after setting profile", %{session: session} do
      session = Session.load_profile(session, "developer_user")
      assert Session.current_stage(session) == :answering_questions
    end

    test "returns :finished after failing", %{session: session} do
      session = Session.load_profile(session, "developer_user")
      {:finished, session} = answer_incorrectly(session, @questions_per_topic)
      assert Session.current_stage(session) == :finished
    end

    test "returns :finished after finishing all questions", %{session: session} do
      session = Session.load_profile(session, "developer_user")

      {:finished, session} =
        answer_correctly(
          session,
          @questions_per_topic * @top_level_topics + @questions_per_topic * @number_of_sub_topics
        )

      assert Session.current_stage(session) == :finished
    end
  end

  describe "load_profile/2" do
    test "sets the included topics", %{session: session} do
      session = Session.load_profile(session, "developer_user")

      assert Enum.sort(Session.Config.included_topics(session.config)) ==
               Enum.sort([
                 "databases",
                 "networks",
                 "data_structures"
               ])
    end

    test "loads the first set of questions", %{session: session} do
      assert session.questions == []
      session = Session.load_profile(session, "developer_user")
      assert session.questions != []
    end
  end
end
