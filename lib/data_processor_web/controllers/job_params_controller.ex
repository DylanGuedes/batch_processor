defmodule DataProcessorWeb.JobParamsController do
  use DataProcessorWeb, :controller

  alias DataProcessor.InterSCity
  alias DataProcessor.InterSCity.JobParams

  @handlers [
    DataProcessor.Handlers.StatisticalDescribe,
    DataProcessor.Handlers.LinearRegression]

  def index(conn, _params),
    do: render(conn, "index.html", job_params: InterSCity.list_job_params())

  def new(conn, _params) do
    changeset = InterSCity.change_job_params(%JobParams{})
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

  def _render_show(conn, job, tab \\ "info"),
    do: render(conn, "show.html", [job: job, current_tab: tab])
  def show(conn, %{"id" => id, "current_tab" => tab}),
    do: _render_show(conn, InterSCity.get_job_params!(id), tab)
  def show(conn, %{"id" => id}),
    do: _render_show(conn, InterSCity.get_job_params!(id))

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
    InterSCity.alter_spark_param(job_params, :update, :schema, field, field_type)
    redirect(conn, to: job_params_path(conn, :show, job_params, current_tab: "schema"))
  end

  def add_interscity_field(conn, %{"id" => id, "field" => field, "value" => value}) do
    job_params = InterSCity.get_job_params!(id)
    InterSCity.alter_spark_param(job_params, :update, :interscity, field, value)
    redirect(conn, to: job_params_path(conn, :show, job_params, current_tab: "interscity"))
  end

  def add_functional_field(conn, %{"id" => id, "field" => field, "value" => value}) do
    job_params = InterSCity.get_job_params!(id)
    InterSCity.alter_spark_param(job_params, :update, :functional_params, field, value)
    redirect(conn, to: job_params_path(conn, :show, job_params, current_tab: "functional"))
  end

  def remove_schema_field(conn, %{"id" => id, "field" => field}) do
    job_params = InterSCity.get_job_params!(id)
    old_schema = Map.get(job_params, :spark_params) |> Map.get("schema")
    new_schema = Map.delete(old_schema, field)
    new_spark_params = Map.get(job_params, :spark_params) |> Map.put("schema", new_schema)

    _changeset =
      InterSCity.update_job_params(%JobParams{} = job_params, %{spark_params: new_spark_params})

    conn
    |> put_flash(:error, "Field #{field} removed from schema.")
    |> redirect(to: job_params_path(conn, :show, job_params))
  end

  def remove_functional_field(conn, %{"id" => id, "field" => field}) do
    job_params = InterSCity.get_job_params!(id)
    IO.inspect job_params
    old_functional_params = Map.get(job_params, :spark_params) |> Map.get("functional_params")
    IO.inspect old_functional_params
    new_functional_params = Map.delete(old_functional_params, field)

    new_spark_params =
      Map.get(job_params, :spark_params) |> Map.put("functional_params", new_functional_params)

    _changeset =
      InterSCity.update_job_params(%JobParams{} = job_params, %{spark_params: new_spark_params})

    conn
    |> put_flash(:error, "Field #{field} removed from functional params.")
    |> redirect(to: job_params_path(conn, :show, job_params))
  end

  def remove_interscity_field(conn, %{"id" => id, "field" => field}) do
    job_params = InterSCity.get_job_params!(id)
    old_interscity_config = Map.get(job_params, :spark_params) |> Map.get("interscity")
    new_interscity_config = Map.delete(old_interscity_config, field)

    new_spark_params =
      Map.get(job_params, :spark_params) |> Map.put("interscity", new_interscity_config)

    _changeset =
      InterSCity.update_job_params(%JobParams{} = job_params, %{spark_params: new_spark_params})

    conn
    |> put_flash(:error, "Field #{field} removed from InterSCity config.")
    |> redirect(to: job_params_path(conn, :show, job_params))
  end

  def update_publish_strategy(conn, %{"id" => id, "strategy" => strategy, "path" => path}) do
    job_params = InterSCity.get_job_params!(id)
    old_publish_strategy = Map.get(job_params, :spark_params) |> Map.get("publish_strategy")

    new_publish_strategy =
      old_publish_strategy
      |> Map.put("name", strategy)
      |> Map.put("path", path)

    new_spark_params =
      job_params
      |> Map.get(:spark_params)
      |> Map.put("publish_strategy", new_publish_strategy)

    InterSCity.update_job_params(%JobParams{} = job_params, %{spark_params: new_spark_params})
    redirect(conn, to: job_params_path(conn, :show, job_params, current_tab: "publish-strategy"))
  end

  def schedule_spark_job(conn, %{"id" => id}) do
    job_params = InterSCity.get_job_params!(id)

    case apply(:"#{job_params.handler}", :handle, [job_params.spark_params]) do
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: job_params_path(conn, :show, job_params))

      {:success, uuid} ->
        InterSCity.increase_scheduled_jobs(job_params)

        conn
        |> put_flash(:info, "Your job is successfully running with UUID #{uuid}")
        |> redirect(to: job_params_path(conn, :show, job_params))
    end
  end

  def clone(conn, %{"id" => id}) do
    job_params = InterSCity.get_job_params!(id)

    case InterSCity.create_job_params(job_params) do
      {:ok, j} ->
        conn
        |> put_flash(:info, "Job params created successfully.")
        |> redirect(to: job_params_path(conn, :show, j))

      {:error, %Ecto.Changeset{} = changeset} ->
        redirect(conn, to: job_params_path(conn, :show, job_params))
    end
  end
end
