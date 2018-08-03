defmodule BatchProcessorWeb.QueryController do
  use BatchProcessorWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end
end
