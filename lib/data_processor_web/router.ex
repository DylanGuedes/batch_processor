defmodule DataProcessorWeb.Router do
  use DataProcessorWeb, :router
  use Coherence.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Coherence.Authentication.Session)
  end

  pipeline :protected do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Coherence.Authentication.Session, protected: true)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/" do
    pipe_through(:browser)
    coherence_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes(:protected)
  end

  scope "/", DataProcessorWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/start_job", JobController, :start_job)
    get("/fade_job", JobController, :fade_job)
    resources("/jobs", JobController, only: [:index])
    resources("/handlers", HandlerController, only: [:index])

    # v2
    resources("/job_templates", JobTemplateController) do
      post("/update_field", FieldController, :update_field)
    end
    get("/schedule_spark_job", JobTemplateController, :schedule_spark_job)
    get("/clone", JobTemplateController, :clone)
  end

  scope "/", DataProcessorWeb do
    pipe_through(:protected)
    post("/add_schema_field", JobParamsController, :add_schema_field)
  end

  scope "/api", DataProcessorWeb do
    pipe_through(:api)
    resources("/templates", API.TemplatesController, only: [:index])
    post("/templates/clone", API.TemplatesController, :clone)
    post("/templates/schedule_job", API.TemplatesController, :schedule_job)
    post("/templates/start_job", API.TemplatesController, :start_job)

    post("/register_job", API.JobController, :register_job)
    post("/jobs/spawn_spark_job", API.JobController, :spawn_spark_job)
    get("/retrieve_params", API.JobController, :retrieve_params)
    get("/start_job", API.JobController, :start_job)
    get("/retrieve_log", API.JobController, :retrieve_log)
    resources("/jobs", API.JobController, only: [:index])
  end
end
