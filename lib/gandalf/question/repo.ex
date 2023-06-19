defmodule Gandalf.Question.Repo do

    alias Gandalf.Question
    
    def all() do
        all("./resources/questions/")
    end

    defp yml_to_model(yml_model) do
        %{"text" => text, "answers" => answers, "correct_answer" => correct_answer} = yml_model
        %Question{question_body: text, answer_choices: answers, correct_answer_index: correct_answer - 1}
    end

    defp all(file) do
        if File.dir?(file) do
            file
            |> File.ls!()
            |> Enum.map(& file <> &1)
            |> Enum.flat_map(&all/1)
        else
            file
            |> YamlElixir.read_from_file!()
            |> Map.get("questions")
            |> Enum.map(&yml_to_model/1)
        end
    end
end