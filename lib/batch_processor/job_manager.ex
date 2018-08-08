defmodule BatchProcessor.JobManager do
  use Agent

  alias BatchProcessor.DockerJob

  @spec start_link(any) :: {atom, pid()}
  def start_link(_opts),
    do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  @spec register_job(String.t(), map) :: String.t()
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

  def fade_job(uuid) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, uuid) end) do
      nil ->
        {:error, "Job not present!"}

      job ->
        DockerJob.suicide(job)
        Agent.update(__MODULE__, fn state -> Map.delete(state, uuid) end)
    end
  end

  @spec retrieve_job_params(String.t()) :: map
  def retrieve_job_params(uuid) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, uuid) end) do
      nil -> %{}
      job -> DockerJob.retrieve_params(job)
    end
  end

  @spec registered_jobs() :: list()
  def registered_jobs,
    do: Agent.get(__MODULE__, fn state -> Map.keys(state) end)

  @spec jobs_list_with_detail() :: list()
  def jobs_list_with_detail do
    Agent.get(__MODULE__, fn state -> Map.keys(state) end)
    |> Enum.map(fn x -> {x, job_pid(x)} end)
    |> Enum.map(fn {x, x_pid} -> {x, x_pid, DockerJob.status(x_pid)} end)
  end

  @spec retrieve_job_log(String.t()) :: String.t()
  def retrieve_job_log(uuid) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, uuid) end) do
      nil -> ""
      job -> DockerJob.retrieve_log(job)
    end
  end

  @spec job_pid(String.t()) :: pid
  def job_pid(uuid) do
    Agent.get(__MODULE__, fn state -> Map.get(state, uuid) end)
  end
end
