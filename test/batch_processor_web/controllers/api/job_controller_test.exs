defmodule BatchProcessorWeb.API.JobControllerTest do
  use BatchProcessorWeb.ConnCase

  alias BatchProcessor.JobManager

  setup do
    _pid = start_supervised!(JobManager)
    {:ok, conn: build_conn()}
  end

  test "submit a simple job with correct params", %{conn: conn} do
    params = %{
      "interscity" => %{
        "capability" => "car_monitoring"
      },
      "schema" => %{
        "kmh" => "double",
      },
      "publish_strategy" => %{
        name: "test"
      },
      "job" => "linear_regression"
    }

    conn = post(conn, job_path(conn, :register_job, params))
    assert json_response(conn, 201)
  end

  test "run job missing params", %{conn: conn} do
    params = %{
      :publish_strategy => %{name: "test"},
      :job => "linear_regression"
    }

    conn = post(conn, job_path(conn, :register_job, params))
    assert json_response(conn, 400) == %{
      "reason" => "Missing param(s) interscity, schema"
    }
  end
end
