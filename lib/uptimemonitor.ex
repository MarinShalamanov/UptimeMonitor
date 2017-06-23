use Amnesia

defmodule UptimeMonitor do
    use Application
    use Supervisor
    
    alias UptimeMonitor.Database.MonitorItem
    
    def start(_type, _args) do
        
        children = [
            Plug.Adapters.Cowboy.child_spec(:http, UptimeMonitor.Router, [], port: 8080),
            supervisor(UptimeMonitor.Supervisor, [])
        ]

        Supervisor.start_link(children, strategy: :one_for_one)
    end
end
