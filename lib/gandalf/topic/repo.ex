defmodule Gandalf.Topic.Repo do
  alias Gandalf.Topic

  def all_topics() do
    "./resources/questions/"
    |> read_all()
    |> Enum.map(fn %{"topic" => topic} -> topic end)
    |> Enum.uniq()
  end

  def subtopics(topic) do
    Enum.filter(all_topics(), &Topic.subtopic_of?(&1, topic))
  end

  defp read_all(file) do
    if File.dir?(file) do
      file
      |> File.ls!()
      |> Enum.map(&(file <> "/" <> &1))
      |> Enum.flat_map(&read_all/1)
    else
      [YamlElixir.read_from_file!(file)]
    end
  end
end
