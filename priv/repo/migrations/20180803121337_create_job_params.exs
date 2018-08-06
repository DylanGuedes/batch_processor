defmodule BatchProcessor.Repo.Migrations.CreateJobParams do
  use Ecto.Migration

  def change do
    create table(:job_params) do
      add :name, :string
      add :spark_params, :map, null: false, default: %{
        schema: %{},
        publish_strategy: %{name: "file", format: "csv"},
        functional_params: %{},
        interscity: %{}}

      timestamps()
    end

  end
end
