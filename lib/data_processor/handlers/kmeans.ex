defmodule DataProcessor.Handlers.KMeans do
  @common_fields ["publish_strategy", "interscity", "schema"]

  alias DataProcessor.JobManager
  use DataProcessor.SparkHandler

  def title() do
    "KMeans Clustering"
  end

  def slug_title() do
    "kmeans_train"
  end

  def description() do
    """
    Cluster a dataset using KMeans.
    """
  end

  def required_params() do
    [
      {"publish_strategy", "Strategy used to publish the kmeans model generated"},
      {"schema", "Schema used to parse the Spark data"}
    ]
  end

  def optional_params() do
    []
  end
end
