defmodule UptimeMonitor.ConfigApp do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, UptimeMonitor.Router, [], port: 8080)
    ]

    Logger.info "Started application on port 8080"

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end