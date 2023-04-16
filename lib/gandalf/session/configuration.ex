defmodule Gandalf.Session.Configuration do
    
    # Roles can be generated dynamically from a dedicated yaml resource.
    # CI can check that it works

    defstruct [roles: []]
end