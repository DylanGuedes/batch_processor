defmodule DataProcessor.SparkHandlerCallbacks do
  @doc "Title to be shown on handlers page"
  @callback title() :: String.t

  @doc "Slug title, to be used in links and tags"
  @callback slug_title() :: String.t

  @doc "Spark job description"
  @callback description() :: String.t

  @doc "Required params to be filled"
  @callback required_params() :: String.t

  @doc ""
  @callback run(m :: map) :: {:success, String.t() }
end

defmodule DataProcessor.SparkHandler do
  defmacro __using__(_params) do
    quote do
      @behaviour DataProcessor.SparkHandlerCallbacks

      @spec missing_keys(map, list) :: list
      def missing_keys(map, keys) do
        keys
        |> Enum.filter(fn key -> Map.fetch(map, key) == :error end)
      end

      @spec missing_params(map) :: list
      def missing_params(params) do
        missing_keys(params, @common_fields)
      end

      @spec run(map) :: {:success, String.t()}
      def run(params) do
        {:success, DataProcessor.JobManager.register_job(slug_title(), params)}
      end

      @spec handle(map) :: {:success | :error, String.t()}
      def handle(params) do
        case missing_params(params) do
          [] -> run(params)
          missing_params_list -> {:error, "Missing param(s) #{Enum.join(missing_params_list, ", ")}"}
        end
      end
    end
  end
end
