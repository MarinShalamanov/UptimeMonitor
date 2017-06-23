use Amnesia

defmodule UptimeMonitor.Configuration do
    require Logger
    
    alias UptimeMonitor.Database.MonitorItem
    
    
    def add_monitor(monitor) do 
        Amnesia.transaction do
            monitor |> MonitorItem.write    
        end
    end
    
    def remove_monitor(url) do    
        Amnesia.transaction do
            url |> MonitorItem.delete
        end
    end

    def all_monitors do
        Amnesia.transaction do 
            MonitorItem.stream |> Enum.to_list
        end
    end
end