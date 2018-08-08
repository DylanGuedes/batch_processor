defmodule BatchProcessor.DockerJobTest do
  use ExUnit.Case

  alias BatchProcessor.DockerJob
  alias BatchProcessor.JobManager

  setup do
    :ok
  end

  test "spawn job with empty spark params" do
    opts = %{
      "uuid" => "asdf",
      "params" => %{
      },
      "spark_job_name" => "linear_regression"
    }

    {:ok, pid} = DockerJob.start_link(opts)
    assert DockerJob.retrieve_log(pid)==""
    assert DockerJob.retrieve_params(pid)==%{}
    assert DockerJob.status(pid)==:ready
  end
end
