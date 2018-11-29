defmodule DataProcessor.InterSCityTest do
  use DataProcessor.DataCase

  alias DataProcessor.InterSCity

  describe "job_templates" do
    alias DataProcessor.InterSCity.JobTemplate

    @valid_attrs %{"title" => "some name", "handler" => "#{DataProcessor.Handlers.LinearRegression}"}
    @update_attrs %{"title" => "some updated name"}
    @invalid_attrs %{"title" => nil}

    def job_template_fixture(attrs \\ %{}) do
      {:ok, job_template} =
        attrs
        |> Enum.into(@valid_attrs)
        |> InterSCity.create_template()

      job_template
    end

    test "list_job_templates/0 returns all job_template" do
      job_template = job_template_fixture()
      assert InterSCity.list_templates() == [job_template]
    end

    test "get_template!/1 returns the template with given id" do
      template = job_template_fixture()
      assert InterSCity.get_template!(template.id) == template
    end

    test "create_template/1 with valid data creates a template" do
      assert {:ok, %JobTemplate{} = job_template} = InterSCity.create_template(@valid_attrs)
      assert job_template.title == "some name"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = InterSCity.create_template(@invalid_attrs)
    end

    test "update_template/2 with valid data updates the job_template" do
      job_template = job_template_fixture()
      assert {:ok, job_template} = InterSCity.update_template(job_template, @update_attrs)
      assert %JobTemplate{} = job_template
      assert job_template.title == "some updated name"
    end

    test "update_template/2 with invalid data returns error changeset" do
      job_template = job_template_fixture()
      assert {:error, %Ecto.Changeset{}} = InterSCity.update_template(job_template, @invalid_attrs)
      assert job_template == InterSCity.get_template!(job_template.id)
    end

    test "delete_template/1 deletes the job_template" do
      job_template = job_template_fixture()
      assert {:ok, %JobTemplate{}} = InterSCity.delete_template(job_template)
      assert_raise Ecto.NoResultsError, fn -> InterSCity.get_template!(job_template.id) end
    end
  end
end
