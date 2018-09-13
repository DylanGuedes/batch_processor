defmodule BatchProcessor.SparkHandler do
  @doc "Title to be shown on handlers page"
  @callback title() :: String.t

  @doc "Slug title, to be used in links and tags"
  @callback slug_title() :: String.t

  @doc "Spark job description"
  @callback description() :: String.t

  @doc "Required params to be filled"
  @callback required_params() :: String.t
end
