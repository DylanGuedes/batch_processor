defmodule BatchProcessorWeb.API.TemplatesController do
  use BatchProcessorWeb, :controller

  alias BatchProcessor.InterSCity

  def index(conn, _params) do
    templates = InterSCity.list_job_params

    conn
    |> put_status(:ok)
    |> render("index.json", templates: templates)
  end
end
