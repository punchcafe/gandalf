defmodule Gandalf.Session.Result do

    @type sub_topic_metric :: {sub_topic :: atom(), score :: integer()}
    @type t() :: %{topic_name :: atom() => [sub_topic_metric]}


    
    # map of topics to sub topics
    # result per sub topic.
    # Rely on algorithm for deriving what to do next from result.
end