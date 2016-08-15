defmodule URLChecker do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(URLChecker.Endpoint, []),
      supervisor(URLChecker.Redis, []),
    ]

    opts = [strategy: :one_for_one, name: URLChecker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    URLChecker.Endpoint.config_change(changed, removed)
    :ok
  end
end
