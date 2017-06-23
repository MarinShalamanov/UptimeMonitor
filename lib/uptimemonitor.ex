use Amnesia

defmodule UptimeMonitor do
    use Application
    
    def start(_type, _args) do
        UptimeMonitor.Supervisor.start_link
    end
end
