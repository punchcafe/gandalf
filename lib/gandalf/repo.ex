defmodule Gandalf.Repo do
  use Ecto.Repo,
    otp_app: :gandalf,
    adapter: Ecto.Adapters.Postgres
end
