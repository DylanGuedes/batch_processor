defmodule BatchProcessor.Repo.Migrations.AddScheduledJobsToJobParams do
  use Ecto.Migration

  def change do
    alter table(:job_params) do
      add :scheduled_jobs, :integer, default: 0
    end
  end
end
