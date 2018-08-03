defmodule BatchProcessor.Repo.Migrations.CreateJobParams do
  use Ecto.Migration

  def change do
    create table(:job_params) do
      add :name, :string
      add :spark_params, :map, null: false, default: %{schema: %{}, free_params: %{}, extras: %{}}

      timestamps()
    end

  end
end
