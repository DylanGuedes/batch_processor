defmodule BatchProcessor.Handlers do
  def list() do
    [
      BatchProcssor.LinearRegressionHandler,
      BatchProcessor.StatisticalDescribeHandler
    ]
  end
end
