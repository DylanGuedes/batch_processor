defmodule BatchProcessorWeb.Router do
  use BatchProcessorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BatchProcessorWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/start_job", JobController, :start_job
    get "/fade_job", JobController, :fade_job
    resources "/job_params", JobParamsController, only: [:index, :show, :new, :create, :edit]
    resources "/jobs", JobController, only: [:index]
    post "/add_schema_field", JobParamsController, :add_schema_field
    post "/add_interscity_field", JobParamsController, :add_interscity_field
    post "/add_functional_field", JobParamsController, :add_functional_field
    post "/update_publish_strategy", JobParamsController, :update_publish_strategy
    get "/remove_schema_field", JobParamsController, :remove_schema_field
    get "/remove_interscity_field", JobParamsController, :remove_interscity_field
    get "/schedule_spark_job", JobParamsController, :schedule_spark_job
    get "/remove_job", JobParamsController, :remove_job
  end

  scope "/api", BatchProcessorWeb do
    pipe_through :api

    post "/register_job", API.JobController, :register_job
    get "/retrieve_params", API.JobController, :retrieve_params
    get "/start_job", API.JobController, :start_job
    get "/retrieve_log", API.JobController, :retrieve_log
    resources "/jobs", API.JobController, only: [:index]
  end
end
