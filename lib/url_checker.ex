defmodule URLChecker do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(URLChecker.Endpoint, []),
      # Start your own worker by calling: URLChecker.Worker.start_link(arg1, arg2, arg3)

      # worker(URLChecker.Worker, [arg1, arg2, arg3]),
    ]

    redis_workers = for i <- 0..(URLChecker.Redis.pool_size - 1) do
      worker(Redix, [[], [name: :"redis_#{i}"]], id: {Redix, i})
    end


    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: URLChecker.Supervisor]
    Supervisor.start_link(children ++ redis_workers, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    URLChecker.Endpoint.config_change(changed, removed)
    :ok
  end
end
