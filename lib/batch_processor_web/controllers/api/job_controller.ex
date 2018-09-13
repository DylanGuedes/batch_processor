defmodule BatchProcessorWeb.API.JobController do
  use BatchProcessorWeb, :controller

  alias BatchProcessor.InterSCity
  alias BatchProcessor.LinearRegressionHandler
  alias BatchProcessor.JobManager
  alias BatchProcessor.DockerJob

  @handlers %{
    "linear_regression" => LinearRegressionHandler
  }

  def register_job(conn, params) do
    case @handlers[params["job"]].handle(params) do
      {:success, job_id} ->
        conn
        |> put_status(:created)
        |> json(%{"job_id" => job_id})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{reason: reason})
    end
  end

  def spawn_spark_job(conn, %{"id" => id}) do
    job_params = InterSCity.get_job_params!(id)

    case apply(:"#{job_params.handler}", :handle, [job_params.spark_params]) do
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: job_params_path(conn, :show, job_params))

      {:success, uuid} ->
        InterSCity.increase_scheduled_jobs(job_params)

        conn
        |> json(%{"uuid": uuid})
    end
  end

  def start_job(conn, %{"job_id" => job_id}) do
    pid = job_id |> JobManager.job_pid()

    spawn(fn -> DockerJob.run(pid) end)

    conn
    |> put_status(:ok)
    |> json(%{})
  end

  def retrieve_params(conn, %{"job_id" => job_id}) do
    params = JobManager.retrieve_job_params(job_id)

    conn
    |> put_status(:ok)
    |> json(params)
  end

  def retrieve_log(conn, %{"job_id" => job_id}) do
    log = JobManager.retrieve_job_log(job_id)

    conn
    |> put_status(:ok)
    |> json(log)
  end

  def index(conn, _params) do
    jobs = JobManager.registered_jobs()

    IO.inspect jobs

    conn
    |> put_status(:ok)
    |> json(%{"jobs" => jobs})
  end
end
