defmodule BatchProcessor.JobManager do
  use Agent

  alias BatchProcessor.DockerJob

  @spec start_link() :: {atom, pid()}
  def start_link,
    do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  @spec register_job(String.t, map) :: String.t
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

  @spec retrieve_job_params(String.t) :: map
  def retrieve_job_params(uuid) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, uuid) end) do
      nil -> %{}
      job -> DockerJob.retrieve_params(job)
    end
  end

  @spec registered_jobs() :: list()
  def registered_jobs,
    do: Agent.get(__MODULE__, fn state -> Map.keys(state) end)

  @spec retrieve_job_log(String.t) :: String.t
  def retrieve_job_log(uuid) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, uuid) end) do
      nil -> ""
      job -> DockerJob.retrieve_log(job)
    end
  end
end
