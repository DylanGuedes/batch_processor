defmodule DataProcessor.Handlers.LinearRegression do

  @common_fields ["publish_strategy", "interscity", "schema"]

  alias DataProcessor.JobManager
  use DataProcessor.SparkHandler

  def title() do
    "Linear Regression Handler"
  end

  def slug_title() do
    "linear-regression-handler"
  end

  def description() do
    """
    Evaluate a linear regression model based on a specific InterSCity capability.
    """
  end

  def required_params() do
    [
      {"publish_strategy", "Strategy used to publish the linear regression model generated"},
      {"schema", "Schema used to parse the Spark data"}
    ]
  end

  def optional_params() do
    [
      {"opt1", "Strategy used to publish the linear regression model generated"},
      {"opt2", "Schema used to parse the Spark data"}
    ]
  end
end
