use Amnesia

defmodule UptimeMonitor.Configuration do
    require Logger
    
    alias UptimeMonitor.Database.MonitorItem
    
    
    def add_monitor do 
        Logger.info "writing..."
        Amnesia.transaction do
            mon = %MonitorItem{url: "https://github.com/", action_on_up: nil, action_on_down: nil, keep_history: true} |> MonitorItem.write!
            
            Logger.info inspect(mon)
        
            mon
        end
    end
    
    def add_monitor(monitor) do 
        Logger.info "writing..."
        Amnesia.transaction do
            monitor |> MonitorItem.write
            
            Logger.info inspect(monitor)
        
            monitor
        end
    end
    
    def remove_monitor(_url) do 
        raise "not implemented"    
    end

    def all_monitors do
        Amnesia.transaction do 
            MonitorItem.stream |> Enum.to_list
        end
    end
end