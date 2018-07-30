defmodule BatchProcessor.LinearRegressionTest do
  use ExUnit.Case

  alias BatchProcessor.DockerJob
  alias BatchProcessor.JobManager
  alias BatchProcessor.LinearRegressionHandler

  setup do
    _pid = start_supervised!(JobManager)
    opts = %{
      "capability" => "house_pricing",
      "publish_strategy" => "console",
      "house_pricing_schema" => %{
        "something" => "integer"
      },
      "params" => "fullll"
    }
    %{opts: opts}
  end

  test "spawn linear regression with correct params", %{opts: opts} do
    assert JobManager.registered_jobs == []
    {:success, uuid} = LinearRegressionHandler.handle(opts)
    assert JobManager.registered_jobs != []
    pid = JobManager.job_pid(uuid)
    assert DockerJob.status(pid) == :ready
    DockerJob.run(pid)
  end
end

