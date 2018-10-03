defmodule DataProcessorWeb.HandlerController do
  use DataProcessorWeb, :controller

  @handlers [
    DataProcessor.Handlers.LinearRegression,
    DataProcessor.Handlers.StatisticalDescribe
  ]

  def index(conn, _params) do
    conn
    |> render("index.html", handlers: @handlers)
  end
end
