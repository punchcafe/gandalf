defmodule Gandalf.Topic do
    @opaque t :: String.t()
    
    defguard is_topic(topic) when is_binary(topic)
    
    def depth(topic) when is_topic(topic) do
        topic
        |> String.split(":")
        |> Enum.count()
    end

end