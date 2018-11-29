defmodule DataProcessorWeb.API.JobTemplateControllerTest do
  use DataProcessorWeb.ConnCase

  alias DataProcessor.Repo
  alias DataProcessor.InterSCity
  alias DataProcessor.InterSCity.JobTemplate

  @create_attrs %{
    "title" => "some name", "handler" => "#{DataProcessor.LinearRegressionHandler}"
  }

  def fixture(:template) do
    {:ok, template} = InterSCity.create_template(@create_attrs)
    template
  end

  describe "index" do
    test "lists all templates", %{conn: conn} do
      conn = get conn, job_template_path(conn, :index)
      assert html_response(conn, 200)
    end
  end

  describe "new template" do
    test "renders form", %{conn: conn} do
      conn = get conn, job_template_path(conn, :new)
      assert html_response(conn, 200) =~ "New"
    end
  end

  describe "create template" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, job_template_path(conn, :create), job_template: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == job_template_path(conn, :show, id)

      conn = get conn, job_template_path(conn, :show, id)
      assert html_response(conn, 200)
    end
  end

  describe "show template" do
    test "correctly show template", %{conn: conn} do
      template = fixture(:template)
      conn = get conn, job_template_path(conn, :show, template.id)
      assert html_response(conn, 200)
    end
  end

  describe "delete template" do
    test "deletes the given template correctly", %{conn: conn} do
      template = fixture(:template)
      old_count = InterSCity.list_templates() |> length()
      delete conn, job_template_path(conn, :delete, template.id)
      new_count = InterSCity.list_templates() |> length()
      assert new_count = old_count-1
    end
  end
end
