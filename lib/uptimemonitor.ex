use Amnesia

defmodule UptimeMonitor do
    use Application
    
    alias UptimeMonitor.Supervisor
    alias UptimeMonitor.Database.MonitorItem
    
    def start(_type, _args) do
        Supervisor.start_link()
    end
end
