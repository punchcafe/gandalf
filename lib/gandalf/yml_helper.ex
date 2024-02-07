defmodule Gandalf.YmlHelper do
  def read_all(file_or_directory) do
    base_path = :gandalf |> :code.priv_dir() |> to_string()
    full_path = base_path <> "/" <> file_or_directory
    if File.dir?(full_path) do
      full_path
      |> File.ls!()
      |> Enum.map(&(file_or_directory <> "/" <> &1))
      |> Enum.flat_map(&read_all/1)
    else
      [YamlElixir.read_from_file!(full_path)]
    end
  end
end
