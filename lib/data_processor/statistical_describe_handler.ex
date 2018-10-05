defmodule DataProcessor.StatisticalDescribeHandler do
  alias DataProcessor.JobManager

  @common_fields ["publish_strategy", "interscity", "schema"]

  def title() do
    "Statistical Describe Handler"
  end

  def slug_title() do
    "statistical-describe-handler"
  end

  def description() do
    """
    Calculate common statistical data of a specific InterSCity capability.
    """
  end

  def required_params() do
    [
      {"publish_strategy", "Strategy used to publish the statistical data calculated"},
      {"schema", "Schema used to parse the Spark data"}
    ]
  end

  def optional_params() do
    []
  end

  @spec missing_keys(map, list) :: list
  def missing_keys(map, keys) do
    keys
    |> Enum.filter(fn key -> Map.fetch(map, key) == :error end)
  end

  @spec missing_params(map) :: list
  def missing_params(params) do
    missing_keys(params, @common_fields)
  end

  @spec run_spark_job(map) :: {:success, String.t()}
  def run_spark_job(params) do
    {:success, JobManager.register_job("statistical_describe", params)}
  end

  @spec handle(map) :: {:success | :error, String.t()}
  def handle(params) do
    case missing_params(params) do
      [] -> run_spark_job(params)
      missing_params_list -> {:error, "Missing param(s) #{Enum.join(missing_params_list, ", ")}"}
    end
  end
end
