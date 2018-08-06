defmodule BatchProcessorWeb.JobParamsController do
  use BatchProcessorWeb, :controller

  alias BatchProcessor.InterSCity
  alias BatchProcessor.InterSCity.JobParams

  def index(conn, _params) do
    job_params = InterSCity.list_job_params()
    render(conn, "index.html", job_params: job_params)
  end

  @handlers [BatchProcessor.LinearRegressionHandler]

  def new(conn, _params) do
    changeset = InterSCity.change_job_params(%JobParams{spark_params: %{
      schema: %{},
      publish_strategy: %{name: "file", format: "csv"},
      functional_params: %{},
      interscity: %{}}})
    render(conn, "new.html", %{handlers: @handlers, changeset: changeset})
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

  def show(conn, %{"id" => id, "current_tab" => tab}) do
    job_params = InterSCity.get_job_params!(id)
    spark_params = Map.get(job_params, :spark_params)
    params = %{}
             |> Map.put("id", id)
             |> Map.put("current_tab", tab)
             |> Map.put("spark_params", spark_params)
             |> Map.put("job_params", job_params)
    _show(conn, params)
  end
  def show(conn, %{"id" => id}) do
    job_params = InterSCity.get_job_params!(id)
    spark_params = Map.get(job_params, :spark_params)
    params = %{}
             |> Map.put("id", id)
             |> Map.put("current_tab", "info")
             |> Map.put("spark_params", spark_params)
             |> Map.put("job_params", job_params)
    _show(conn, params)
  end
  def _show(conn, params) do
    spark_params = Map.get(params, "spark_params")
    job_params = Map.get(params, "job_params")
    tab = Map.get(params, "current_tab")
    render(conn, "show.html", [spark_params: spark_params, job: job_params, current_tab: tab])
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

  def remove_job(conn, %{"id" => id}) do
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
    redirect(conn, to: job_params_path(conn, :show, job_params, [current_tab: "schema"]))
  end

  def remove_schema_field(conn, %{"id" => id, "field" => field}) do
    job_params = InterSCity.get_job_params!(id)
    old_schema = Map.get(job_params, :spark_params) |> Map.get("schema")
    new_schema = Map.delete(old_schema, field)
    new_spark_params = Map.get(job_params, :spark_params) |> Map.put("schema", new_schema)
    changeset = InterSCity.update_job_params(%JobParams{} = job_params, %{spark_params: new_spark_params})
    conn
    |> put_flash(:error, "Field #{field} removed from schema.")
    |> redirect(to: job_params_path(conn, :show, job_params))
  end

  def schedule_spark_job(conn, %{"id" => id}) do
    job_params = InterSCity.get_job_params!(id)
    case apply(:"#{job_params.handler}", :handle, [job_params.spark_params]) do
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: job_params_path(conn, :show, job_params))
      {:success, uuid} ->
        IO.puts "UUID: #{uuid}"
        conn
        |> put_flash(:info, "Your job is successfully running with UUID #{uuid}")
        |> redirect(to: job_params_path(conn, :show, job_params))
    end
  end

  def update_publish_strategy(conn, %{"id" => id, "strategy" => strategy, "path" => path}) do
    job_params = InterSCity.get_job_params!(id)
    old_publish_strategy = Map.get(job_params, :spark_params) |> Map.get("publish_strategy")
    new_publish_strategy = old_publish_strategy
      |> Map.put("name", strategy)
      |> Map.put("path", path)

    new_spark_params = job_params
                       |> Map.get(:spark_params)
                       |> Map.put("publish_strategy", new_publish_strategy)

    sch = InterSCity.update_job_params(%JobParams{} = job_params, %{spark_params: new_spark_params})
    IO.puts "sch:"
    IO.inspect sch
    IO.puts "end sch"
    redirect(conn, to: job_params_path(conn, :show, job_params, [current_tab: "publish-strategy"]))
  end
end
