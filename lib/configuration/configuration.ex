use Amnesia

defmodule UptimeMonitor.Configuration do
    require Logger
    
    alias UptimeMonitor.Database.MonitorItem
    alias UptimeMonitor.Database.History
    
    
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

    
    @spec get_history(String.t | :all) :: [History.t]
    def get_history(url) do 
        Amnesia.transaction do 
            url   
            |> History.get 
            |> List.flatten
            |> Enum.sort_by(fn(x) -> x.time end, &>=/2)
        end 
    end 
end