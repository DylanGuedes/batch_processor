defmodule BatchProcessorWeb.API.JobParamsControllerTest do
  use BatchProcessorWeb.ConnCase

  alias BatchProcessor.InterSCity

  @create_attrs %{"name" => "some name", "handler" => "#{BatchProcessor.LinearRegressionHandler}"}
  @invalid_attrs %{"name" => nil}

  def fixture(:job_params) do
    {:ok, job_params} = InterSCity.create_job_params(@create_attrs)
    job_params
  end

  describe "index" do
    test "lists all job_params", %{conn: conn} do
      conn = get conn, job_params_path(conn, :index)
      assert html_response(conn, 200)
    end
  end

  describe "new job_params" do
    test "renders form", %{conn: conn} do
      conn = get conn, job_params_path(conn, :new)
      assert html_response(conn, 200) =~ "New Job params"
    end
  end

  describe "create job_params" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, job_params_path(conn, :create), job_params: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == job_params_path(conn, :show, id)

      conn = get conn, job_params_path(conn, :show, id)
      assert html_response(conn, 200)
    end
  end

  defp create_job_params(_) do
    job_params = fixture(:job_params)
    {:ok, job_params: job_params}
  end
end
