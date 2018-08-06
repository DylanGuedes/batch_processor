defmodule BatchProcessorWeb.JobView do
  use BatchProcessorWeb, :view

  def row_state(:ready),
    do: ""
  def row_state(:finished),
    do: "positive"
  def row_state(:running),
    do: "negative"
end
