defmodule BatchProcessor.InterSCity.JobParams do
  use Ecto.Schema
  import Ecto.Changeset

  schema "job_params" do
    field :name, :string
    field :spark_params, :map, default: %{
      schema: %{},
      publish_strategy: %{name: "file", format: "csv"},
      functional_params: %{},
      interscity: %{}}
    field :handler, :string
    field :scheduled_jobs, :integer

    timestamps()
  end

  def changeset(job_params, attrs) do
    job_params
    |> cast(attrs, [:spark_params, :name, :handler, :scheduled_jobs])
    |> validate_required([:name, :handler, :spark_params])
  end

  def update_changeset(job_params, attrs) do
    job_params
    |> cast(attrs, [:name, :spark_params, :handler, :scheduled_jobs])
    |> validate_required([:name, :handler])
    |> validate_blank_schema_field()
  end

  def _validate_blank_schema_field(:error, changeset) do
    spark_params = %{
      schema: %{},
      publish_strategy: %{name: "file", format: "csv"},
      functional_params: %{},
      interscity: %{}}
    changeset(changeset, %{spark_params: spark_params})
  end
  def _validate_blank_schema_field({:ok, spark_params}, changeset) do
    spark_schema = Map.get(spark_params, "schema")
    case Map.has_key?(spark_schema, "") do
      true -> add_error(changeset, :spark_params, "Empty field in schema")
      false -> changeset
    end
  end

  def validate_blank_schema_field(changeset) do
    changeset
    |> Map.fetch!(:changes)
    |> Map.fetch(:spark_params)
    |> _validate_blank_schema_field(changeset)
  end
end
