defmodule DataProcessor.Handlers.LinearRegressionTest do
  use ExUnit.Case

  alias DataProcessor.DockerJob
  alias DataProcessor.JobManager
  alias DataProcessor.Handlers.LinearRegression

  setup do
    _pid = start_supervised!(JobManager)
    opts = %{
      "publish_strategy" => %{
        "name" => "console"
      },
      "functional_params" => %{
        "test_split" => "0.2"
      },
      "schema" => %{
        "zip" => "integer"
      },
      "interscity" => %{
        "capability" => "house_pricing"
      }
    }
    %{opts: opts}
  end

  test "spawn linear regression with correct params", %{opts: opts} do
    assert JobManager.registered_jobs == []
    {:success, uuid} = LinearRegression.handle(opts)
    assert JobManager.registered_jobs != []
    pid = JobManager.job_pid(uuid)
    assert DockerJob.status(pid) == :ready
    DockerJob.run(pid)
  end
end

