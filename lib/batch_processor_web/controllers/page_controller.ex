defmodule BatchProcessorWeb.PageController do
  use BatchProcessorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
