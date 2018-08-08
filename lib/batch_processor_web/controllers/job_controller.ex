defmodule BatchProcessorWeb.JobController do
  use BatchProcessorWeb, :controller

  alias BatchProcessor.LinearRegressionHandler
  alias BatchProcessor.JobManager
  alias BatchProcessor.DockerJob

  def index(conn, _params) do
    jobs = JobManager.jobs_list_with_detail

    conn
    |> render("index.html", jobs: jobs)
  end

  def start_job(conn, %{"uuid" => uuid}) do
    pid = uuid |> JobManager.job_pid
    
    spawn(fn -> DockerJob.run(pid) end)

    conn
    |> put_flash(:info, "Job successfully started!")
    |> redirect(to: job_path(conn, :index))
  end

  def fade_job(conn, %{"uuid" => uuid}) do
    JobManager.fade_job(uuid)

    conn
    |> put_flash(:error, "Job successfully erased!")
    |> redirect(to: job_path(conn, :index))
  end
end
