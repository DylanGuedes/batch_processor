defmodule DataProcessorWeb.FieldController do
  use DataProcessorWeb, :controller

  alias DataProcessor.Repo
  alias DataProcessor.InterSCity
  alias DataProcessor.InterSCity.JobTemplate

  def update_field(conn, %{"job_template_id" => id, "table" => t, "command" => "drop", "key" => k}) do
    template = InterSCity.get_template!(id)
    {:ok, old_table} = Map.fetch(template.params, t)
    new_table = Map.delete(old_table, k)
    new_params = template.params |> Map.put(t, new_table)
    JobTemplate.changeset(template, %{params: new_params}) |> Repo.update!
    redirect(conn, to: job_template_path(conn, :show, template, current_tab: t))
  end

  def update_field(conn, %{"table" => t, "command" => "update", "key" => k, "value" => v, "job_template_id" => id}) do
    template = InterSCity.get_template!(id)
    {:ok, old_table} = Map.fetch(template.params, t)
    new_table = Map.put(old_table, k, v)
    new_params = template.params |> Map.put(t, new_table)
    JobTemplate.changeset(template, %{params: new_params}) |> Repo.update!
    redirect(conn, to: job_template_path(conn, :show, template, current_tab: t))
  end

  def update_field(conn, %{"table" => t, "command" => "update", "strategy" => s, "path" => p, "job_template_id" => id}) do
    template = InterSCity.get_template!(id)
    {:ok, old_table} = Map.fetch(template.params, t)
    new_table = Map.put(old_table, "strategy", s) |> Map.put("path", p)
    new_params = template.params |> Map.put(t, new_table)
    JobTemplate.changeset(template, %{params: new_params}) |> Repo.update!
    redirect(conn, to: job_template_path(conn, :show, template, current_tab: "publish_strategy"))
  end
end
