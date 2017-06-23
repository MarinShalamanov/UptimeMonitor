
defmodule UptimeMonitor.Supervisor do
    use Supervisor
    
    @moduledoc """
    The main supervisor of the application. Supervised the administration 
    panel (http server) and the MonitorSupervisor (which handles the monitor logic). 
    """
    
    def start_link do
        Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    end
 
    def init(_) do
        children = [
            Plug.Adapters.Cowboy.child_spec(:http, UptimeMonitor.AdminPanel.Router, [], port: 8080),
            supervisor(UptimeMonitor.Core.MonitorSupervisor, [])
        ]
        
        opts = [strategy: :one_for_one]
        
        supervise(children, opts)
    end
end