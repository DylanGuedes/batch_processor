defmodule BatchProcessorWeb.API.JobParamsControllerTest do
  use BatchProcessorWeb.ConnCase

  alias BatchProcessor.InterSCity

  @create_attrs %{"name" => "some name", "handler" => "#{BatchProcessor.LinearRegressionHandler}"}

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

  describe "update spark_params" do
    test "it changes schema correctly", %{conn: conn} do
      job_params = fixture(:job_params)
      current_schema = job_params.spark_params["schema"]
      assert current_schema == %{}
      post_params = %{
        "id" => job_params.id,
        "field" => "abc",
        "field_type" => "string"}
      conn = post conn, job_params_path(conn, :add_schema_field), post_params
      assert html_response(conn, 302)
      new_job_params = InterSCity.get_job_params!(job_params.id)
      new_schema = new_job_params.spark_params["schema"]
      assert new_schema == %{"abc" => "string"}

      params = %{"id" => job_params.id, "field" => "abc"}
      conn = get conn, job_params_path(conn, :remove_schema_field), params
      assert html_response(conn, 302)
      new_job_params = InterSCity.get_job_params!(job_params.id)
      new_schema = new_job_params.spark_params["schema"]
      assert new_schema == %{}
    end

    test "it changes functional fields correctly", %{conn: conn} do
      job_params = fixture(:job_params)
      current_functional_params = job_params.spark_params["functional_params"]
      assert current_functional_params == %{}
      post_params = %{
        "id" => job_params.id,
        "field" => "abc",
        "value" => "efg"}
      conn = post conn, job_params_path(conn, :add_functional_field), post_params
      assert html_response(conn, 302)
      new_job_params = InterSCity.get_job_params!(job_params.id)
      new_functional_params = new_job_params.spark_params["functional_params"]
      assert new_functional_params == %{"abc" => "efg"}
    end

    test "it changes interscity fields correctly", %{conn: conn} do
      job_params = fixture(:job_params)
      current_functional_params = job_params.spark_params["functional_params"]
      assert current_functional_params == %{}
      post_params = %{
        "id" => job_params.id,
        "field" => "abc",
        "value" => "efg"}
      conn = post conn, job_params_path(conn, :add_functional_field), post_params
      assert html_response(conn, 302)
      new_job_params = InterSCity.get_job_params!(job_params.id)
      new_functional_params = new_job_params.spark_params["functional_params"]
      assert new_functional_params == %{"abc" => "efg"}
    end

    test "it changes publish strategy correctly", %{conn: conn} do
      job_params = fixture(:job_params)
      current_publish_strat = job_params.spark_params["publish_strategy"]
      assert current_publish_strat == %{"name" => "file", "format" => "csv"}
      post_params = %{
        "id" => job_params.id,
        "strategy" => "abc",
        "path" => "efg"}
      conn = post conn, job_params_path(conn, :update_publish_strategy), post_params
      assert html_response(conn, 302)
      new_job_params = InterSCity.get_job_params!(job_params.id)
      new_publish_strat = new_job_params.spark_params["publish_strategy"]
      assert new_publish_strat == %{"name" => "abc", "format" => "csv", "path" => "efg"}
    end
  end
end
