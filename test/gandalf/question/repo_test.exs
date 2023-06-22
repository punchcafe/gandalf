defmodule Gandalf.Question.RepoTest do
  use ExUnit.Case, async: false
  alias Gandalf.Topic
  alias Gandalf.Question.Repo
  alias Gandalf.Question

  describe "all/2" do
    test "returns Question structs" do
      assert [%Question{} | _] = Repo.all()
    end

    test "only returns topics of expected depth" do
      for depth <- [1, 2] do
        topic_depths =
          depth
          |> Repo.all()
          |> Enum.map(& &1.topic)
          |> Enum.map(&Topic.depth/1)
          |> Enum.uniq()

        assert [depth] == topic_depths
      end
    end
  end

  describe "all/2: filtering" do
    test "filtering by super topic includes all subtopics" do
      question_topics =
        2
        |> Repo.all(include: "networks")
        |> Enum.map(& &1.topic)
        |> Enum.uniq()

      assert ["networks:tcp", "networks:http"] == question_topics
    end

    test ":include and :exclude parameters can be strings or lists of strings" do
      for filter_key <- [:include, :exclude] do
        Repo.all(1, [{filter_key, "databases"}]) == Repo.all(1, [{filter_key, ["databases"]}])
      end
    end

    test "can filter :include by multiple topics" do
      question_topics =
        1
        |> Repo.all(include: ["databases", "data_structures"])
        |> Enum.map(& &1.topic)
        |> Enum.uniq()

      assert ["data_structures", "databases"] == question_topics
    end

    test "can filter :exclude by multiple topics" do
      question_topics =
        1
        |> Repo.all(exclude: ["databases", "data_structures"])
        |> Enum.map(& &1.topic)
        |> Enum.uniq()

      assert ["networks"] == question_topics
    end

    test "can compose include and exclude filtering to only retrieve certain topics" do
      question_topics =
        2
        |> Repo.all(include: "networks", exclude: "networks:tcp")
        |> Enum.map(& &1.topic)
        |> Enum.uniq()

      assert ["networks:http"] == question_topics
    end
  end
end
