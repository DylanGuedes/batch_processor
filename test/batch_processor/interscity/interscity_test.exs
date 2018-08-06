defmodule BatchProcessor.InterSCityTest do
  use BatchProcessor.DataCase

  alias BatchProcessor.InterSCity

  describe "job_params" do
    alias BatchProcessor.InterSCity.JobParams

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def job_params_fixture(attrs \\ %{}) do
      {:ok, job_params} =
        attrs
        |> Enum.into(@valid_attrs)
        |> InterSCity.create_job_params()

      job_params
    end

    test "list_job_params/0 returns all job_params" do
      job_params = job_params_fixture()
      assert InterSCity.list_job_params() == [job_params]
    end

    test "get_job_params!/1 returns the job_params with given id" do
      job_params = job_params_fixture()
      assert InterSCity.get_job_params!(job_params.id) == job_params
    end

    test "create_job_params/1 with valid data creates a job_params" do
      assert {:ok, %JobParams{} = job_params} = InterSCity.create_job_params(@valid_attrs)
      assert job_params.name == "some name"
    end

    test "create_job_params/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = InterSCity.create_job_params(@invalid_attrs)
    end

    test "update_job_params/2 with valid data updates the job_params" do
      job_params = job_params_fixture()
      assert {:ok, job_params} = InterSCity.update_job_params(job_params, @update_attrs)
      assert %JobParams{} = job_params
      assert job_params.name == "some updated name"
    end

    test "update_job_params/2 with invalid data returns error changeset" do
      job_params = job_params_fixture()
      assert {:error, %Ecto.Changeset{}} = InterSCity.update_job_params(job_params, @invalid_attrs)
      assert job_params == InterSCity.get_job_params!(job_params.id)
    end

    test "delete_job_params/1 deletes the job_params" do
      job_params = job_params_fixture()
      assert {:ok, %JobParams{}} = InterSCity.delete_job_params(job_params)
      assert_raise Ecto.NoResultsError, fn -> InterSCity.get_job_params!(job_params.id) end
    end

    test "change_job_params/1 returns a job_params changeset" do
      job_params = job_params_fixture()
      assert %Ecto.Changeset{} = InterSCity.change_job_params(job_params)
    end
  end
end
