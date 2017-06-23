
defmodule UptimeMonitor.Supervisor do
    use Supervisor
    
    
    alias UptimeMonitor.Master
    alias UptimeMonitor.MonitorSupervisor
    
    def start_link do
        Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    end
    
    def init(_args) do
        children = [
            supervisor(MonitorSupervisor, []),
            worker(Master, [])
        ]

        supervise(children, strategy: :rest_for_one)
    end
end