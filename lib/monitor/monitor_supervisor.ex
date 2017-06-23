
defmodule UptimeMonitor.MonitorSupervisor do 
    use Supervisor
    
    alias UptimeMonitor.Worker
    
    require Logger
    
    def start_link do
        Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    end
    
    
    def init(_args) do
        children = [
          worker(Worker, [], restart: :transient)
        ]

        opts = [strategy: :simple_one_for_one, 
            max_restarts: 3,
            max_seconds: 30]
        
        supervise(children, opts)
    end

    def start_child (monitor) do
        Logger.info("starting worker for " <> inspect(monitor))
            
        Supervisor.start_child(__MODULE__, [monitor])
    end
end