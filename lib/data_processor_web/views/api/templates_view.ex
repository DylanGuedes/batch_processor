defmodule DataProcessorWeb.API.TemplatesView do
  use DataProcessorWeb, :view

  def render("index.json", %{templates: templates}),
    do: %{templates: Enum.map(templates, &template_json/1)}

  def template_json(template),
    do: %{
      handler: template.handler,
      id: template.id,
      inserted_at: template.inserted_at,
      name: template.name,
      scheduled_jobs: template.scheduled_jobs,
      spark_params: template.spark_params
    }
end
