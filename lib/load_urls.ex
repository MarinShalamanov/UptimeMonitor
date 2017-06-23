
defmodule LoadUrls do
    
    use Amnesia 
    alias UptimeMonitor.Database.MonitorItem
    
    def url_list(count) do 
        File.stream!("test/data/top-1m.csv") 
        |> Enum.map( fn(str) -> 
            String.split(str, [",", "\n"]) 
            |> Enum.at(1) 
            end )
        |> Enum.take(count) 
    end
    
    def load(count) when is_integer(count) do 
        url_list(count)
        |> Enum.map(fn(url) -> 
            %MonitorItem{
                url: url, 
                action_on_up: nil, 
                action_on_down: nil, 
                keep_history: true,
                time_interval: 1}
            end)
        |> Enum.map(fn(item) -> 
                Amnesia.transaction do 
                    MonitorItem.write(item)    
                end
            end )
    end 
end