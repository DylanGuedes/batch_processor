defmodule DataProcessorWeb.PageController do
  use DataProcessorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
