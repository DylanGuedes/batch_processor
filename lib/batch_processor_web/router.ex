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

    resources "/job_params", JobParamsController
    post "/add_schema_field", JobParamsController, :add_schema_field
  end

  scope "/api", BatchProcessorWeb do
    pipe_through :api

    post "/register_job", JobController, :register_job
    get "/retrieve_params", JobController, :retrieve_params
    get "/start_job", JobController, :start_job
    get "/retrieve_log", JobController, :retrieve_log
    get "/jobs", JobController, :index
  end
end
