defmodule DataProcessorWeb.API.FieldControllerTest do
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

  describe "update fields" do
    test "it correctly update keys", %{conn: conn} do
      template = fixture(:template)
      old_params = template.params

      new_params =
        template.params |> Map.put("functional_params", %{"iterations" => 15})

      t = JobTemplate.changeset(template, %{params: new_params}) |> Repo.update!

      {:ok, f_params} = template.id
                        |> InterSCity.get_template!
                        |> Map.get(:params)
                        |> Map.fetch("functional_params")
      assert f_params = %{"iterations" => 15}

      request_params = %{
        command: "drop",
        table: "functional_params",
        id: template.id,
        key: "iterations"
      }
      conn = post conn, job_template_field_path(conn, :update_field, template.id), request_params
      {:ok, f_params} = template.id
                        |> InterSCity.get_template!
                        |> Map.get(:params)
                        |> Map.fetch("functional_params")
      assert f_params = %{}

      request_params = %{
        command: "update",
        table: "functional_params",
        job_template_id: template.id,
        key: "awesome-key",
        value: "nice123"
      }
      conn = post conn, job_template_field_path(conn, :update_field, template.id), request_params
      {:ok, f_params} = template.id
                        |> InterSCity.get_template!
                        |> Map.get(:params)
                        |> Map.fetch("functional_params")
      assert f_params = %{"awesome-key" => "nice123"}
    end
  end
end
