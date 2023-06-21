defmodule Gandalf.Question.Repo do
  alias Gandalf.{Topic, Question}

  def all(depth \\ 1, query \\ []) do
    exclude_list = Keyword.get(query, :exclude, [])

    "./resources/questions/"
    |> read_all()
    |> Enum.filter(&matches_depth?(&1, depth))
    |> Enum.reject(fn %{"topic" => topic} -> topic_excluded?(topic, exclude_list) end)
    |> Enum.flat_map(&Map.get(&1, "questions"))
    |> Enum.map(&yml_to_model/1)
  end

  defp topic_excluded?(topic, exclude_list) do
    Enum.any?(exclude_list, fn excluded_topic ->
      excluded_topic == topic or Topic.subtopic_of?(topic, excluded_topic)
    end)
  end

  defp matches_depth?(_resouce_yaml = %{"topic" => topic}, depth), do: Topic.depth(topic) == depth

  defp yml_to_model(yml_model) do
    %{"text" => text, "answers" => answers, "correct_answer" => correct_answer} = yml_model

    %Question{
      question_body: text,
      answer_choices: answers,
      correct_answer_index: correct_answer - 1
    }
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
