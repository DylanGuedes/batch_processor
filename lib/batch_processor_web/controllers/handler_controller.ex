defmodule BatchProcessorWeb.HandlerController do
  use BatchProcessorWeb, :controller

  @handlers [BatchProcessor.LinearRegressionHandler]

  def index(conn, _params) do
    conn
    |> render("index.html", handlers: @handlers)
  end
end
