defmodule BatchProcessor.DockerJob do
  use GenServer

  def init(initial_state),
    do: {:ok, initial_state}

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

  def retrieve_log(pid) do
    GenServer.call(pid, :retrieve_log)
  end

  def retrieve_params(pid) do
    GenServer.call(pid, :retrieve_params)
  end

  def status(pid) do
    GenServer.call(pid, :retrieve_state)
  end

  def run(pid) do
    GenServer.cast(pid, :run)
  end

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

  def handle_call(:retrieve_log, _from, state) do
    {:reply, state["log"], state}
  end

  def handle_call(:retrieve_state, _from, state) do
    {:reply, state["state"], state}
  end

  def handle_call(:retrieve_params, _from, state) do
    {:reply, state["spark_params"], state}
  end
end
