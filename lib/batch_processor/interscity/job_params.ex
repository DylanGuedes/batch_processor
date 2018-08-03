defmodule BatchProcessor.InterSCity.JobParams do
  use Ecto.Schema
  import Ecto.Changeset


  schema "job_params" do
    field :name, :string
    field :spark_params, :map

    timestamps()
  end

  @doc false
  def changeset(job_params, attrs) do
    job_params
    |> cast(attrs, [:name, :spark_params])
    |> validate_required([:name])
  end
end
