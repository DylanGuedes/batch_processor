defmodule DataProcessor.Application do
  use Application

  @dialyzer [
    {:nowarn_function, start: 2}
  ]

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(DataProcessor.Repo, []),
      supervisor(DataProcessorWeb.Endpoint, [])
    ]

    children =
      case Application.get_env(:data_processor, :environment) do
        :test -> children
        _ -> children ++ [{DataProcessor.JobManager, []}]
      end

    # Define workers and child supervisors to be supervised

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DataProcessor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DataProcessorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
