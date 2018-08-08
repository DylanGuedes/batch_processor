defmodule BatchProcessor.JobManagerTest do
  use ExUnit.Case

  alias BatchProcessor.JobManager

  setup do
    _pid = start_supervised!(JobManager)
    :ok
  end

  test "correctly add jobs to its state", %{} do
    assert JobManager.registered_jobs == []
    uuid = JobManager.register_job("nice_name", %{"a" => "1"})
    assert JobManager.retrieve_job_params(uuid) == %{"a" => "1"}
    assert JobManager.registered_jobs != []
  end
end
