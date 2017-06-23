defmodule UptimeMonitorTest.Core.Master do
    use ExUnit.Case
  
    alias UptimeMonitor.Core.Monitor
    alias UptimeMonitor.Core.Worker
    alias UptimeMonitor.Database.MonitorItem
    alias UptimeMonitor.Database.History
    alias UptimeMonitor.Configuration
    
    use Amnesia
    
    setup do 
        urls = Configuration.all_monitors |> List.flatten |> Enum.map(fn x -> x.url end)

        Amnesia.transaction do 
            urls
            |> Enum.map(&MonitorItem.delete/1)
        end

        :ok
    end

    test "new worker is spawned when adding new monitor item and killed when item is deleted" do
        url = "https://google.com/"
        monitor = %MonitorItem{url: url, action_on_up: nil, action_on_down: nil, keep_history: false, time_interval: 1}
    
        {:global, name} = (url |> Worker.ref)
        
        assert not worker_alive?(url)

        Configuration.add_monitor(monitor)    

        :timer.sleep(2000)
        
        assert worker_alive?(url)

        Configuration.remove_monitor(url)
        
        :timer.sleep(2000)
        
        assert not worker_alive?(url)
    end

    test "there are active workers for all monitor items" do 
        num = 10
        LoadUrls.load(num)
        
        :timer.sleep(5000)

        LoadUrls.url_list(num) 
        |> Enum.map(fn url -> assert worker_alive?(url) end) 
    end
    
    defp worker_for_url (url) do 
        {:global, name} = (url |> Worker.ref)
        :global.whereis_name(name) 
    end

    defp worker_alive? (url) do 
        worker_for_url(url) != :undefined
    end
end