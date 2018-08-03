defmodule BatchProcessorWeb.JobParamsController do
  use BatchProcessorWeb, :controller

  alias BatchProcessor.InterSCity
  alias BatchProcessor.InterSCity.JobParams

  def index(conn, _params) do
    job_params = InterSCity.list_job_params()
    render(conn, "index.html", job_params: job_params)
  end

  def new(conn, _params) do
    changeset = InterSCity.change_job_params(%JobParams{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"job_params" => job_params_params}) do
    case InterSCity.create_job_params(job_params_params) do
      {:ok, job_params} ->
        conn
        |> put_flash(:info, "Job params created successfully.")
        |> redirect(to: job_params_path(conn, :show, job_params))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    job_params = InterSCity.get_job_params!(id)
    IO.inspect job_params
    spark_params = Map.get(job_params, :spark_params)
    render(conn, "show.html", [spark_params: spark_params, job: job_params])
  end

  def edit(conn, %{"id" => id}) do
    job_params = InterSCity.get_job_params!(id)
    changeset = InterSCity.change_job_params(job_params)
    render(conn, "edit.html", job_params: job_params, changeset: changeset)
  end

  def update(conn, %{"id" => id, "job_params" => job_params_params}) do
    job_params = InterSCity.get_job_params!(id)

    case InterSCity.update_job_params(job_params, job_params_params) do
      {:ok, job_params} ->
        conn
        |> put_flash(:info, "Job params updated successfully.")
        |> redirect(to: job_params_path(conn, :show, job_params))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", job_params: job_params, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    job_params = InterSCity.get_job_params!(id)
    {:ok, _job_params} = InterSCity.delete_job_params(job_params)

    conn
    |> put_flash(:info, "Job params deleted successfully.")
    |> redirect(to: job_params_path(conn, :index))
  end

  def add_schema_field(conn, %{"id" => id, "field" => field, "field_type" => field_type}) do
    job_params = InterSCity.get_job_params!(id)
    old_schema = Map.get(job_params, :spark_params) |> Map.get("schema")
    new_schema = Map.put(old_schema, field, field_type)
    new_spark_params = Map.get(job_params, :spark_params) |> Map.put("schema", new_schema)
    InterSCity.update_job_params(%JobParams{} = job_params, %{spark_params: new_spark_params})
    redirect(conn, to: job_params_path(conn, :show, job_params))
  end
end
