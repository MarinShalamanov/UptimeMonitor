
defmodule UptimeMonitor.Supervisor do
    use Supervisor
    
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