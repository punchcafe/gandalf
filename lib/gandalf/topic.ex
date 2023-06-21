defmodule Gandalf.Topic do
  @opaque t :: String.t()

  defguard is_topic(topic) when is_binary(topic)

  def depth(topic) when is_topic(topic) do
    topic
    |> as_list()
    |> Enum.count()
  end

  def subtopic_of?(topic, maybe_super_topic)
      when is_binary(topic) and is_binary(maybe_super_topic) do
    subtopic_of?(as_list(topic), as_list(maybe_super_topic))
  end

  def subtopic_of?([h | lhs_rest], [h | rhs_rest]), do: subtopic_of?(lhs_rest, rhs_rest)

  def subtopic_of?([_ | _], []) do
    true
  end

  def subtopic_of?(_, _), do: false

  defp as_list(topic), do: String.split(topic, ":")
end
