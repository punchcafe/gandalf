defmodule Gandalf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GandalfWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Gandalf.PubSub},
      # Start Finch
      {Finch, name: Gandalf.Finch},
      # Start the Endpoint (http/https)
      GandalfWeb.Endpoint
      # Start a worker by calling: Gandalf.Worker.start_link(arg)
      # {Gandalf.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gandalf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GandalfWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
