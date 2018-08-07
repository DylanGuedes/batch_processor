defmodule BatchProcessorWeb.JobView do
  use BatchProcessorWeb, :view

  def row_state_color(:ready),
    do: "warning"
  def row_state_color(:finished),
    do: "positive"
  def row_state_color(:running),
    do: "negative"

  def row_state_text(:ready),
    do: "Ready to start"
  def row_state_text(:finished),
    do: "Job Finished"
  def row_state_text(:running),
    do: "Running"

  def row_state_extra_icon(:ready),
    do: "attention icon"
  def row_state_extra_icon(state),
    do: ""
end
