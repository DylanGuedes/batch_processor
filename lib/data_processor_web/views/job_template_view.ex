defmodule DataProcessorWeb.JobTemplateView do
  use DataProcessorWeb, :view

  def active_tab_tag(tab, tab),
    do: "active"

  def active_tab_tag(current_tab, tab),
    do: ""
end
