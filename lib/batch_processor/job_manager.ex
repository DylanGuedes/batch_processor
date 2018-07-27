defmodule BatchProcessor.JobManager do
  use Agent

  def start_link,
    do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  def register_job(uuid, params) do
    Agent.update(__MODULE__, fn state -> Map.put(state, uuid, {:running, params}) end)
    spawn_docker_job(uuid)
    uuid
  end

  def spawn_docker_job(uuid) do
    docker_arguments = [
      "exec",
      "-d", # exec mode
      "master", # container name
      "spark-submit",
      "/jobs/#{job_name}.py"] ++ publish_strategy_opts ++ capabilities_schema ++ ["--others"] ++ other_params

    log = System.cmd("docker", docker_arguments,  stderr_to_stdout: true)
  end

  def retrieve_job_params(uuid) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, uuid) end) do
      nil -> {:invalid, %{}}
      {_, params} -> params
    end
  end

  def registered_jobs,
    do: Agent.get(__MODULE__, fn state -> Map.keys(state) end)
end
