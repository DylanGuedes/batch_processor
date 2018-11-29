defmodule DataProcessor.InterSCity do
  import Ecto.Query, warn: false
  alias DataProcessor.Repo

  alias DataProcessor.InterSCity.JobTemplate

  def list_templates do
    Repo.all(JobTemplate)
  end

  def get_template!(id), do: Repo.get!(JobTemplate, id)

  def clone_template(%JobTemplate{} = template) do
    changeset_params = %{
      title: template.title,
      handler: template.handler,
      params: template.params
    }
    JobTemplate.changeset(%JobTemplate{}, changeset_params) |> Repo.insert
  end

  def create_template(attrs \\ %{}) do
    initial_params = %{
      "schema" => %{},
      "publish_strategy" => %{"title" => "file", "format" => "csv"},
      "functional_params" => %{},
      "interscity" => %{}
    }

    attrs =
      attrs
      |> Map.put("params", initial_params)

    %JobTemplate{}
    |> JobTemplate.changeset(attrs)
    |> Repo.insert()
  end

  def update_template(%JobTemplate{}=struct, attrs) do
    JobTemplate.changeset(struct, attrs)
    |> Repo.update()
  end
  def update_template(changeset, attrs) do
    changeset
    |> JobTemplate.changeset(attrs)
    |> Repo.update()
  end

  def delete_template(%JobTemplate{} = job_template) do
    Repo.delete(job_template)
  end

  def increase_scheduled_jobs(template) do
    changeset = JobTemplate.changeset(template, %{})
    scheduled_jobs = template.scheduled_jobs
    update_template(changeset, %{scheduled_jobs: scheduled_jobs + 1})
  end

  def alter_param(template, command, table, key, value) do
    old_params =
      template
      |> Map.get(:params)
      |> Map.fetch!("#{table}")

    new_params =
      case command do
        :update -> Map.put(old_params, key, value)
        :remove -> Map.delete(old_params, key)
      end

    final_params =
      template
      |> Map.get(:params)
      |> Map.put(table, new_params)

    update_template(template, %{params: final_params})
  end
end
