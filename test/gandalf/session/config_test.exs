defmodule Gandalf.Session.ConfigTest do
  alias Gandalf.Session.Config
  use ExUnit.Case

  describe "new/1" do
    test "raises exception if unknown key" do
      assert_raise RuntimeError, fn -> Config.new(unknown: :opts) end
    end

    test "raises exception if missing keys" do
      assert_raise ArgumentError, fn -> Config.new([]) end
    end

    test "returns config struct when valid keys provided" do
      questions_per_topic = 6
      failure_threshold = 0.5
      max_topic_suggestions = 5

      assert %Config{
               questions_per_topic: questions_per_topic,
               failure_threshold: failure_threshold,
               max_topic_suggestions: max_topic_suggestions,
               included_topics: ["databases"]
             } ==
               Config.new(
                 questions_per_topic: questions_per_topic,
                 failure_threshold: failure_threshold,
                 max_topic_suggestions: max_topic_suggestions,
                 included_topics: ["databases"]
               )
    end
  end
end
