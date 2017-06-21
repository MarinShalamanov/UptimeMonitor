
defmodule UptimeMonitor.MonitorSupervisor do 
    use Supervisor
    
    alias UptimeMonitor.MonitorWorker
    
    require Logger
    
    def start_link do
        Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    end
    
    
    def init(_args) do
        children = [
          worker(MonitorWorker, [], restart: :transient)
        ]

        supervise(children, strategy: :simple_one_for_one)
    end

    def start_child (monitor) do
        Logger.info("starting worker for " <> inspect(monitor))
        
        Supervisor.start_child(__MODULE__, [monitor])
    end
end