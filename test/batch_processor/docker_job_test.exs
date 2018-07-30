defmodule BatchProcessor.DockerJobTest do
  use ExUnit.Case

  alias BatchProcessor.DockerJob
  alias BatchProcessor.JobManager

  setup do
    _pid = start_supervised!(JobManager)
    :ok
  end

  test "spawn job" do
  end
end

