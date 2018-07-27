defmodule BatchProcessor.LinearRegressionHandler do
  alias BatchProcessor.JobManager

  @common_fields ["publish_strategy", "capability"]

  def missing_keys(map, keys) do
    keys
    |> Enum.filter(fn(key) -> Map.fetch(map, key) == :error end)
  end

  def missing_params(params) do
    case missing_keys(params, @common_fields) do
      [] ->
        schema_field = "#{params["capability"]}_schema"
        missing_keys(params, [schema_field])
      missing_params_list -> missing_params_list
    end
  end

  def run_linear_regression(params) do
    {:success, JobManager.register_job("linear_regression", params)}
  end

  def handle(params) do
    case missing_params(params) do
      [] -> run_linear_regression(params)
      missing_params_list -> {:error, "Missing param(s) #{missing_params_list}"}
    end
  end
end
