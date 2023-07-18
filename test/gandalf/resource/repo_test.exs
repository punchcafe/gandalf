defmodule Gandalf.Resource.RepoTest do
  use ExUnit.Case

  alias Gandalf.Resource.Repo

  describe "topic_resources/1" do
    test "returns a map grouped by topic for matching topics" do
      assert %{
               "databases:rds" => [
                 %Gandalf.Resource{
                   topic: "databases:rds",
                   name: "Use the Index, Luke",
                   description:
                     "A Series of articles guiding you through, the intricacies of performance tuning\n",
                   link: "https://use-the-index-luke.com/"
                 }
               ]
             } == Repo.topic_resources(["databases:rds"])
    end

    test "doesn't include a map entry if nothing found for a topic" do
      assert %{} == Repo.topic_resources(["unknown_topic"])
    end
  end
end
