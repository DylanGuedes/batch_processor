defmodule BatchProcessor.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(BatchProcessor.Repo, []),
      supervisor(BatchProcessorWeb.Endpoint, [])
    ]

    children = case Mix.env do
      :test -> children
      _ -> children ++ [{BatchProcessor.JobManager, []}]
    end

    # Define workers and child supervisors to be supervised

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BatchProcessor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BatchProcessorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
