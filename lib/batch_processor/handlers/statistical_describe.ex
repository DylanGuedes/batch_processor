defmodule DataProcessor.Handlers.StatisticalDescribe do
  alias DataProcessor.JobManager

  @common_fields ["publish_strategy", "interscity", "schema"]

  use DataProcessor.SparkHandler

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
end
