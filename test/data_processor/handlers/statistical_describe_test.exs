defmodule DataProcessor.Handlers.StatisticalDescribeTest do
  use ExUnit.Case

  alias DataProcessor.DockerJob
  alias DataProcessor.JobManager
  alias DataProcessor.Handlers.StatisticalDescribe

  setup do
    _pid = start_supervised!(JobManager)
    opts = %{
      "publish_strategy" => %{
        "name" => "console"
      },
      "functional_params" => %{ },
      "schema" => %{
        "zip" => "integer"
      },
      "interscity" => %{
        "capability" => "house_pricing"
      }
    }
    %{opts: opts}
  end

  test "spawn statistical describe with correct params", %{opts: opts} do
    assert JobManager.registered_jobs == []
    {:success, uuid} = StatisticalDescribe.handle(opts)
    assert JobManager.registered_jobs != []
    pid = JobManager.job_pid(uuid)
    assert DockerJob.status(pid) == :ready
    DockerJob.run(pid)
  end
end

