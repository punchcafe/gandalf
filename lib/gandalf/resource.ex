defmodule Gandalf.Resource do
  @type t :: %__MODULE__{
          topic: Topic.t(),
          name: String.t(),
          description: String.t(),
          link: URI.t()
        }
  defstruct [:topic, :name, :description, :link]
end
