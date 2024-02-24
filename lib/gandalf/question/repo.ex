defmodule Gandalf.Question.Repo do
  alias Gandalf.{Topic, Question}
  import Gandalf.YmlHelper

  def all(depth \\ 1, query \\ []) do
    exclude_list = query_list(query, :exclude)
    include_list = query_list(query, :include)

    :gandalf
    |> Application.fetch_env!(Gandalf.Question.Repo)
    |> Keyword.get(:questions_dir)
    |> read_all()
    |> Stream.filter(&matches_depth?(&1, depth))
    |> Enum.reject(fn %{"topic" => topic} -> topic_matches?(topic, exclude_list) end)
    |> Enum.filter(fn %{"topic" => topic} ->
      if include_list == [] do
        true
      else
        topic_matches?(topic, include_list)
      end
    end)
    |> Enum.flat_map(&extract_questions/1)
  end

  defp query_list(query_opts, key) do
    case Keyword.get(query_opts, key, []) do
      filter_values when is_list(filter_values) -> filter_values
      filter_values when is_binary(filter_values) -> [filter_values]
    end
  end

  defp topic_matches?(topic, topic_list) do
    Enum.any?(topic_list, fn topic_in_list ->
      topic_in_list == topic or Topic.subtopic_of?(topic, topic_in_list)
    end)
  end

  defp extract_questions(%{"topic" => topic, "questions" => questions}) do
    Enum.map(questions, &yml_to_model(&1, topic))
  end

  defp matches_depth?(_resouce_yaml = %{"topic" => topic}, depth), do: Topic.depth(topic) == depth

  defp yml_to_model(yml_model, topic) do
    %{"text" => text, "answers" => answers, "correct_answer" => correct_answer} = yml_model

    %Question{
      question_body: text,
      answer_choices: answers,
      correct_answer_index: correct_answer - 1,
      topic: topic
    }
  end
end
