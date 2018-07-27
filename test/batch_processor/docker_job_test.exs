defmodule BatchProcessor.DockerJobTest do
  use ExUnit.Case, async: true

  alias BatchProcessor.DockerJob

  setup do
    opts = %{
      "uuid" => "1234",
      "params" => %{},
      "spark_job_name" => "linear_regression"
    }

    %{docker_job: start_supervised!({DockerJob, opts})}
  end

  test "spawn job", %{docker_job: docker_job} do
    assert DockerJob.retrieve_log(docker_job) == ""
    assert DockerJob.status(docker_job) == :ready
    DockerJob.run(docker_job)
    assert DockerJob.status(docker_job) == :finished
    assert DockerJob.retrieve_log(docker_job) =~ "ok then"
  end
end

