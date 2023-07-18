defmodule Gandalf.Resource.Repo do
  alias Gandalf.Resource

  import Gandalf.YmlHelper

  @spec topic_resources(topic :: [String.t()]) :: %{Topic.t() => Gandalf.Resource.t()}
  def topic_resources(topics) when is_list(topics) do
    "./resources/resources/"
    |> read_all()
    |> Enum.flat_map(& &1)
    |> Enum.filter(&(&1["topic"] in topics))
    |> Enum.map(&to_model/1)
    |> Enum.group_by(& &1.topic)
  end

  defp to_model(%{"name" => name, "description" => description, "uri" => uri, "topic" => topic}) do
    %Resource{name: name, description: description, link: uri, topic: topic}
  end
end
