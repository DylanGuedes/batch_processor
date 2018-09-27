defmodule DataProcessorWeb.QueryController do
  use DataProcessorWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end
end
