defmodule DataProcessorWeb.API.TemplatesController do
  use DataProcessorWeb, :controller

  alias DataProcessor.InterSCity
  alias DataProcessor.JobManager
  alias DataProcessor.DockerJob

  def index(conn, _params) do
    templates = InterSCity.list_templates

    conn
    |> put_status(:ok)
    |> render("index.json", templates: templates)
  end

  def clone(conn, %{"id" => id}) do
    template = InterSCity.get_template!(id)
    {:ok, new_template} = InterSCity.clone_template(template)

    conn
    |> put_status(:ok)
    |> render("show.json", template: new_template)
  end

  def show(conn, %{"id" => id}) do
    template = InterSCity.get_template!(id)

    conn
    |> put_status(:ok)
    |> render("show.json", template: template)
  end

  def schedule_job(conn, %{"id" => id}) do
    template = InterSCity.get_template!(id)

    case apply(:"#{template.handler}", :handle, [template.params]) do
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> render("error.json")

      {:success, uuid} ->
        InterSCity.increase_scheduled_jobs(template)

        job = %{uuid: uuid, template_id: template.id}

        conn
        |> put_status(:ok)
        |> render("schedule_job.json", job: job)
    end
  end

  def start_job(conn, %{"uuid" => uuid}) do
    pid = uuid |> JobManager.job_pid()
    spawn(fn -> DockerJob.run(pid) end)
    conn
    |> put_status(:ok)
    |> json(%{status: "ok"})
  end
end
