defmodule BatchProcessor.JobManager do
  use Agent

  alias BatchProcessor.DockerJob

  def start_link,
    do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  def register_job(spark_job_name, params) do
    uuid = Ecto.UUID.generate()
    opts = %{
      "uuid" => uuid,
      "params" => params,
      "spark_job_name" => spark_job_name
    }

    {:ok, pid} = DockerJob.start_link(opts)
    Agent.update(__MODULE__, fn state -> Map.put(state, uuid, pid) end)
    uuid
  end

  def retrieve_job_params(uuid) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, uuid) end) do
      nil -> {:invalid, "Non Existent Job", %{}}
      job -> DockerJob.retrieve_params(job)
    end
  end

  def registered_jobs,
    do: Agent.get(__MODULE__, fn state -> Map.keys(state) end)

  def retrieve_job_log(uuid) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, uuid) end) do
      nil -> {:invalid, "Non Existent Job", %{}, ""}
      job -> DockerJob.retrieve_log(job)
    end
  end
end
