defmodule DataProcessor.InterSCity.JobTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "job_templates" do
    field(:title, :string)

    field(:params, :map,
      default: %{
        schema: %{},
        publish_strategy: %{name: "file", format: "csv"},
        functional_params: %{},
        interscity: %{}
      }
    )

    field(:handler, :string)
    field(:scheduled_jobs, :integer, default: 0)

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:params, :title, :handler, :scheduled_jobs])
    |> validate_required([:title, :handler, :params])
  end

  def update_changeset(struct, attrs) do
    IO.puts "[DEBUG] updatE_changeset "
    struct
    |> cast(attrs, [:title, :params, :handler, :scheduled_jobs])
    |> validate_required([:title, :handler])
    |> validate_blank_schema_field()
  end

  def _validate_blank_schema_field(:error, changeset) do
    params = %{
      schema: %{},
      publish_strategy: %{name: "file", format: "csv"},
      functional_params: %{},
      interscity: %{}
    }

    changeset(changeset, %{params: params})
  end

  def _validate_blank_schema_field({:ok, params}, changeset) do
    spark_schema = Map.get(params, :schema)

    case Map.has_key?(spark_schema, "") do
      true -> add_error(changeset, :params, "Empty field in schema")
      false -> changeset
    end
  end

  def validate_blank_schema_field(changeset) do
    changeset
    |> Map.fetch!(:changes)
    |> Map.fetch(:params)
    |> _validate_blank_schema_field(changeset)
  end
end
