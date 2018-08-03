defmodule BatchProcessorWeb.JobParamsControllerTest do
  use BatchProcessorWeb.ConnCase

  alias BatchProcessor.InterSCity

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:job_params) do
    {:ok, job_params} = InterSCity.create_job_params(@create_attrs)
    job_params
  end

  describe "index" do
    test "lists all job_params", %{conn: conn} do
      conn = get conn, job_params_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Job params"
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
      assert html_response(conn, 200) =~ "Show Job params"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, job_params_path(conn, :create), job_params: @invalid_attrs
      assert html_response(conn, 200) =~ "New Job params"
    end
  end

  describe "edit job_params" do
    setup [:create_job_params]

    test "renders form for editing chosen job_params", %{conn: conn, job_params: job_params} do
      conn = get conn, job_params_path(conn, :edit, job_params)
      assert html_response(conn, 200) =~ "Edit Job params"
    end
  end

  describe "update job_params" do
    setup [:create_job_params]

    test "redirects when data is valid", %{conn: conn, job_params: job_params} do
      conn = put conn, job_params_path(conn, :update, job_params), job_params: @update_attrs
      assert redirected_to(conn) == job_params_path(conn, :show, job_params)

      conn = get conn, job_params_path(conn, :show, job_params)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, job_params: job_params} do
      conn = put conn, job_params_path(conn, :update, job_params), job_params: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Job params"
    end
  end

  describe "delete job_params" do
    setup [:create_job_params]

    test "deletes chosen job_params", %{conn: conn, job_params: job_params} do
      conn = delete conn, job_params_path(conn, :delete, job_params)
      assert redirected_to(conn) == job_params_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, job_params_path(conn, :show, job_params)
      end
    end
  end

  defp create_job_params(_) do
    job_params = fixture(:job_params)
    {:ok, job_params: job_params}
  end
end
