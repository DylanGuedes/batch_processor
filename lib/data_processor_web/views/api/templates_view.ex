defmodule DataProcessorWeb.API.TemplatesView do
  use DataProcessorWeb, :view

  def render("index.json", %{templates: templates}),
    do: %{templates: Enum.map(templates, &template_json/1)}

  def render("show.json", %{template: template}),
    do: template_json(template)

  def template_json(template),
    do: %{
      handler: template.handler,
      id: template.id,
      inserted_at: template.inserted_at,
      title: template.title,
      scheduled_jobs: template.scheduled_jobs,
      params: template.params
    }

  def render("error.json", %{reason: reason}),
    do: %{reason: reason}

  def render("schedule_job.json", %{job: job}),
    do: %{job: job}
end
