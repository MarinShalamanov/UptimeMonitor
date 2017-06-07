use Amnesia

defmodule UptimeMonitor.Configuration do
    require Logger
    
    alias UptimeMonitor.Database.MonitorItem
    
    
    def add_monitor do 
        Logger.info "writing..."
        Amnesia.transaction do
            mon = %MonitorItem{url: "https://github.com/", action_on_up: nil, action_on_down: nil, keep_history: nil} |> MonitorItem.write!
            
            Logger.info inspect(mon)
        
            mon
        end
    end
    
    def add_monitor(_url, _action_on_down, _action_on_up, _keep_history) do 

    end
    
    def remove_monitor(_url) do 
        raise "not implemented"    
    end
end