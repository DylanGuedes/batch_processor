defmodule DataProcessor.Repo.Migrations.AddHandlerToJobTemplate do
  use Ecto.Migration

  def change do
    alter table(:job_templates) do
      add :handler, :string
    end
  end
end
