defmodule BatchProcessorWeb.JobControllerTest do
  use BatchProcessorWeb.ConnCase

  alias BatchProcessor.JobManager

  setup do
    _pid = start_supervised!(JobManager)
    {:ok, conn: build_conn()}
  end

  test "submit a simple job with correct params", %{conn: conn} do
    params = %{
      "capability" => ["car_monitoring"],
      "car_monitoring_schema" => ["kmh", "double"],
      "publish_strategy" => %{"name": "test"},
      "job" => "linear_regression"
    }

    conn = post(conn, job_path(conn, :run_job, params))
    assert json_response(conn, 201)
  end

  test "run job missing params", %{conn: conn} do
    params = %{
      "publish_strategy" => %{"name": "test"},
      "job" => "linear_regression"
    }

    conn = post(conn, job_path(conn, :run_job, params))
    assert json_response(conn, 400) == %{
      "reason" => "Missing param(s) capability"
    }
  end

  test "retrieve params", %{conn: conn} do
    params = %{
      "capability" => ["car_monitoring"],
      "car_monitoring_schema" => ["kmh", "double"],
      "publish_strategy" => %{"name" => "test"},
      "job" => "linear_regression"
    }

    job_id = conn
    |> post(job_path(conn, :run_job, params))
    |> Map.get(:resp_body)
    |> Poison.decode!
    |> Map.get("job_id")
    
    conn = get(conn, job_path(conn, :retrieve_params, %{"job_id" => job_id}))

    assert json_response(conn, 200)==params
  end
end
