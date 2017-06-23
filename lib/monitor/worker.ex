
defmodule UptimeMonitor.Worker do 
    use GenServer
    
    alias UptimeMonitor.Monitor;
    alias UptimeMonitor.Database.MonitorItem;
    
    require Logger
    
    def start_link() do
        GenServer.start_link(__MODULE__, nil)
    end
    
    def start_link(monitor) do
        Logger.info("start_link with: " <> inspect(monitor))
        
        
        GenServer.start_link(__MODULE__, monitor, name: ref(monitor))
    end
    
    def init(monitor) do
        Logger.info("gen server init with: " <> inspect(monitor))
        
        schedule_next_check(monitor.time_interval)
        {:ok, monitor}
    end
    
    def handle_info(:check, monitor) do
        Monitor.monitor(monitor)    
        
        schedule_next_check(monitor.time_interval)
        {:noreply, monitor}
    end
    
    def handle_info(mess, monitor) do
        Logger.debug("worder " <> inspect(monitor) <> " received message " <> inspect(mess) )
        
        {:noreply, monitor}
    end
    
    def handle_cast(:inactivate, state) do
        {:stop, :normal, state}
    end
    
    defp schedule_next_check(mins) do 
        Process.send_after(self(), :check, mins * 60 * 1000); 
    end
    
    def ref(%MonitorItem{url: url}) do
        {:global, {:monitor, url}}
    end
    
    def ref(url), do: {:global, {:monitor, url}}
end