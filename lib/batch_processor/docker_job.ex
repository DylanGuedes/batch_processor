defmodule BatchProcessor.DockerJob do
  @moduledoc """
  * Module that represents interaction with Spark Docker jobs.

  ## Usage

      iex> opts = %{
        "uuid" => "abcde",
        "params" => %{},
        "spark_job_name" => "linear_regression"
      }
      ...

      iex> {:ok, pid} = DockerJob.start_link(opts)
      {:ok, #PID<0.9999.0>}
      iex> DockerJob.status(pid)
      :ready
      iex> DockerJob.run(pid)
      :ok
      iex> DockerJob.status(pid)
      :finished
      iex> DockerJob.retrieve_log(pid)
      "Such a great container log, huh?"
  """

  use GenServer

  @spec init(map) :: {:ok, map}
  def init(initial_state),
    do: {:ok, initial_state}

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

  @spec retrieve_params(pid) :: map
  def retrieve_params(pid) do
    GenServer.call(pid, :retrieve_params)
  end

  @spec status(pid) :: map
  def status(pid) do
    GenServer.call(pid, :retrieve_state)
  end

  @spec run(pid) :: atom
  def run(pid) do
    GenServer.cast(pid, :run)
  end

  @spec handle_cast(atom, map) :: {:noreply, map}
  def handle_cast(:run, state) do
    docker_arguments = [
      "exec",
      "-i", # exec mode
      "master", # container name
      "spark-submit",
      "/jobs/#{state["spark_job_name"]}.py",
      state["uuid"]
    ]

    state = Map.put(state, "state", :running)
    {logs, 0} = System.cmd("docker", docker_arguments, stderr_to_stdout: true)
    state = state |> Map.put("state", :finished) |> Map.put("log", logs)
    {:noreply, state}
  end

  @spec handle_call(atom, any, map) :: {:reply, any, map}
  def handle_call(:retrieve_log, _from, state),
    do: {:reply, state["log"], state}
  def handle_call(:retrieve_state, _from, state),
    do: {:reply, state["state"], state}
  def handle_call(:retrieve_params, _from, state),
    do: {:reply, state["spark_params"], state}
end
