defmodule Mix.Tasks.ValidateResources do
  require Logger

  def run([schema_file, resource_directory]) do
    schema =
      schema_file
      |> File.read!()
      |> Jason.decode!()

    schema |> check_file(resource_directory) |> handle_errors()
  end

  defp check_file(schema, file) do
    if File.dir?(file) do
      file
      |> File.ls!()
      |> Enum.flat_map(&check_file(schema, file <> "/" <> &1))
    else
      resource = YamlElixir.read_from_file!(file)

      case ExJsonSchema.Validator.validate(schema, resource) do
        :ok -> []
        {:error, errors} -> [{file, errors}]
      end
    end
  end

  defp handle_errors([]), do: exit(:normal)

  defp handle_errors(errors) do
    error_log =
      Enum.flat_map(errors, fn {file, file_errors} ->
        ["  #{file}:" | Enum.map(file_errors, &"    #{inspect(&1)}")]
      end)

    ["Failed to validate resources against schema. Found the following errors:\n" | error_log]
    |> Enum.join("\n")
    |> Logger.error()

    exit({:shutdown, 1})
  end
end
