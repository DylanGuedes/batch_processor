defmodule BatchProcessorWeb.JobController do
  use BatchProcessorWeb, :controller

  alias BatchProcessor.LinearRegressionHandler
  alias BatchProcessor.JobManager
  alias BatchProcessor.DockerJob

  def index(conn, _params) do
    jobs = JobManager.jobs_list_with_detail
    IO.inspect jobs

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
end
