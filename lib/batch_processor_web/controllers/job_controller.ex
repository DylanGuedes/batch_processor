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
end
