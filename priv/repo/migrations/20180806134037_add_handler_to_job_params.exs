defmodule BatchProcessor.Repo.Migrations.AddHandlerToJobParams do
  use Ecto.Migration

  def change do
    alter table(:job_params) do
      add :handler, :string
    end
  end
end
