defmodule DataProcessor.Repo.Migrations.CreateJobTemplate do
  use Ecto.Migration

  def change do
    create table(:job_templates) do
      add :title, :string
      add :params, :map, null: false, default: %{
        schema: %{},
        publish_strategy: %{name: "file", format: "csv"},
        functional_params: %{},
        interscity: %{}}

      timestamps()
    end

  end
end
