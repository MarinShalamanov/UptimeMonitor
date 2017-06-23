
defmodule UptimeMonitor.Core.MonitorSupervisor do
    use Supervisor
    
    
    alias UptimeMonitor.Core.Master
    alias UptimeMonitor.Core.WorkerSupervisor
    
    def start_link do
        Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    end
    
    def init(_args) do
        children = [
            supervisor(WorkerSupervisor, []),
            worker(Master, [])
        ]

        supervise(children, strategy: :rest_for_one)
    end
end