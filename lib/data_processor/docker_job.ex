defmodule DataProcessor.DockerJob do
  @moduledoc """
  * Module that represents interaction with Spark Docker jobs.

  ## Usage
  iex> alias DataProcessor.DockerJob
  iex> opts = %{"uuid" => "abcde",
  ...> "spark_job_name" => "linear_regression",
  ...> "params" => %{"schema" => %{}}}
  iex> {:ok, pid} = DockerJob.start_link(opts)
  iex> DockerJob.status(pid)
  :ready
  iex> DockerJob.run(pid)
  :ok
  iex> DockerJob.status(pid)
  :running
  iex> DockerJob.retrieve_params(pid)
  %{
    "schema" => %{}
  }
  """

  use GenServer

  @spec init(map) :: {:ok, map}
  def init(initial_state) do
    {:ok, initial_state}
  end

  @spec start_link(map) :: {atom, pid}
  def start_link(opts) do
    initial_state = %{
      "state" => :ready,
      "spark_params" => opts["params"],
      "spark_job_name" => opts["spark_job_name"],
      "log" => "",
      "uuid" => opts["uuid"]
    }

    GenServer.start_link(__MODULE__, initial_state, [])
  end

  @spec retrieve_log(pid) :: map
  def retrieve_log(pid) do
    GenServer.call(pid, :retrieve_log)
  end

  @spec suicide(pid) :: true
  def suicide(pid) do
    Process.exit(pid, :suicide)
  end

  @spec retrieve_params(pid) :: map
  def retrieve_params(pid) do
    GenServer.call(pid, :retrieve_params)
  end

  @spec status(pid) :: atom
  def status(pid) do
    case Process.info(pid) do
      nil -> :error
      _ -> GenServer.call(pid, :retrieve_state)
    end
  end

  @spec run(pid) :: atom
  def run(pid) do
    GenServer.cast(pid, :run)
  end

  @spec handle_cast(atom, map) :: {:noreply, map}
  def handle_cast(:run, state) do
    docker_arguments = [
      "exec",
      # container name
      "master",
      "spark-submit",
      "/jobs/python/#{state["spark_job_name"]}.py",
      state["uuid"]
    ]

    state = Map.put(state, "state", :running)
    pid = self()

    spawn(fn ->
      {log, status} = System.cmd("docker", docker_arguments, stderr_to_stdout: true)

      case status do
        0 -> GenServer.cast(pid, {:finished, log, status})
        _ -> GenServer.cast(pid, {:error, log, status})
      end

      GenServer.cast(pid, {:finished, log, status})
    end)

    {:noreply, state}
  end

  def handle_cast({:finished, log, status}, state) do
    state =
      state
      |> Map.put("state", :finished)
      |> Map.put("log", log)
      |> Map.put("final_status", status)

    {:noreply, state}
  end

  def handle_cast({:error, log, status}, state) do
    state =
      state
      |> Map.put("state", :error)
      |> Map.put("log", log)
      |> Map.put("final_status", status)

    {:noreply, state}
  end

  @spec handle_call(atom, any, map) :: {:reply, any, map}
  def handle_call(:retrieve_log, _from, state),
    do: {:reply, state["log"], state}

  def handle_call(:retrieve_state, _from, state),
    do: {:reply, state["state"], state}

  def handle_call(:retrieve_params, _from, state) do
    {:reply, state["spark_params"], state}
  end

  def terminate(:normal, state),
    do: state

  def terminate(_reason, state) do
    state
  end

  @spec handle_info(tuple, map) :: {:stop, String.t(), map}
  def handle_info({:EXIT, _from, reason}, state) do
    {:stop, reason, state}
  end
end
