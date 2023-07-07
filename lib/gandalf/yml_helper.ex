defmodule Gandalf.YmlHelper do
  def read_all(file_or_directory) do
    if File.dir?(file_or_directory) do
      file_or_directory
      |> File.ls!()
      |> Enum.map(&(file_or_directory <> "/" <> &1))
      |> Enum.flat_map(&read_all/1)
    else
      [YamlElixir.read_from_file!(file_or_directory)]
    end
  end
end
