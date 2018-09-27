defmodule DataProcessorWeb.HandlerController do
  use DataProcessorWeb, :controller

  @handlers [
    DataProcessor.LinearRegressionHandler,
    DataProcessor.StatisticalDescribeHandler
  ]

  def index(conn, _params) do
    conn
    |> render("index.html", handlers: @handlers)
  end
end
