defmodule DataProcessor.Repo.Migrations.AddScheduledJobsToJobTemplate do
  use Ecto.Migration

  def change do
    alter table(:job_templates) do
      add :scheduled_jobs, :integer, default: 0
    end
  end
end
