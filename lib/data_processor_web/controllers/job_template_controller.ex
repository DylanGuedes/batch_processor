defmodule DataProcessorWeb.JobTemplateController do
  use DataProcessorWeb, :controller

  alias DataProcessor.Repo
  alias DataProcessor.InterSCity
  alias DataProcessor.InterSCity.JobTemplate

  @handlers [
    DataProcessor.Handlers.StatisticalDescribe,
    DataProcessor.Handlers.LinearRegression,
    DataProcessor.Handlers.KMeans
  ]

  def delete(conn, %{"id" => id}) do
    template = InterSCity.get_template!(id)
    {:ok, _job_template} = InterSCity.delete_template(template)

    conn
    |> put_flash(:info, "Template deleted successfully.")
    |> redirect(to: job_template_path(conn, :index))
  end

  def index(conn, _params),
    do: render(conn, "index.html", templates: InterSCity.list_templates())

  def new(conn, _params) do
    changeset = JobTemplate.changeset(%JobTemplate{}, %{})
    render(conn, "new.html", %{handlers: @handlers, changeset: changeset})
  end

  def create(conn, %{"job_template" => template_params}) do
    case InterSCity.create_template(template_params) do
      {:ok, template} ->
        conn
        |> put_flash(:info, "Template created successfully.")
        |> redirect(to: job_template_path(conn, :show, template))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def _render_show(conn, template, tab \\ "info"),
    do: render(conn, "show.html", [template: template, current_tab: tab])
  def show(conn, %{"id" => id, "current_tab" => tab}),
    do: _render_show(conn, InterSCity.get_template!(id), tab)
  def show(conn, %{"id" => id}),
    do: _render_show(conn, InterSCity.get_template!(id))

  def edit(conn, %{"id" => id}) do
    template = InterSCity.get_template!(id)
    changeset = JobTemplate.changeset(template, %{})
    render(conn, "edit.html", %{template: template, changeset: changeset, handler: @handlers})
  end

  def update(conn, %{"id" => id, "job_template" => job_template_params}) do
    job_template = InterSCity.get_template!(id)

    case InterSCity.update_template(job_template, job_template_params) do
      {:ok, job_template} ->
        conn
        |> put_flash(:info, "Job params updated successfully.")
        |> redirect(to: job_template_path(conn, :show, job_template))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", params: job_template, changeset: changeset)
    end
  end

  def schedule_spark_job(conn, %{"id" => id}) do
    template = InterSCity.get_template!(id)

    case apply(:"#{template.handler}", :handle, [template.params]) do
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: job_template_path(conn, :show, template))

      {:success, uuid} ->
        InterSCity.increase_scheduled_jobs(template)

        conn
        |> put_flash(:info, "Your job is successfully running with UUID #{uuid}")
        |> redirect(to: job_template_path(conn, :show, template))
    end
  end

  def clone(conn, %{"id" => id}) do
    job_template = InterSCity.get_template!(id)

    case InterSCity.clone_template(job_template) do
      {:ok, j} ->
        conn
        |> put_flash(:info, "Template created successfully.")
        |> redirect(to: job_template_path(conn, :show, j))

      {:error, %Ecto.Changeset{} = changeset} ->
        redirect(conn, to: job_template_path(conn, :show, job_template))
    end
  end
end
