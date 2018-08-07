defmodule BatchProcessor.LinearRegressionHandler do
  alias BatchProcessor.JobManager

  @common_fields ["publish_strategy", "interscity", "schema"]

  @spec missing_keys(map, list) :: list
  def missing_keys(map, keys) do
    keys
    |> Enum.filter(fn(key) -> Map.fetch(map, key) == :error end)
  end

  @spec missing_params(map) :: list
  def missing_params(params) do
    missing_keys(params, @common_fields)
  end

  @spec run_linear_regression(map) :: {:success, String.t}
  def run_linear_regression(params) do
    {:success, JobManager.register_job("linear_regression", params)}
  end

  @spec handle(map) :: {:success | :error, String.t}
  def handle(params) do
    case missing_params(params) do
      [] -> run_linear_regression(params)
      missing_params_list -> {:error, "Missing param(s) #{Enum.join(missing_params_list, ", ")}"}
    end
  end
end
