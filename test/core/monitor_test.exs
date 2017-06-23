defmodule UptimeMonitorTest.Core.Monitor do
    use ExUnit.Case
  
    alias UptimeMonitor.Core.Monitor
    alias UptimeMonitor.Database.MonitorItem
    alias UptimeMonitor.Database.History
    
    use Amnesia
    
    test "url that return redirect" do
        google_monitor = %MonitorItem{url: "https://google.com/", action_on_up: nil, action_on_down: nil, keep_history: false}
    
        assert {:ok, {:up, _}} = Monitor.monitor(google_monitor)
    end


    test "url that return redirect 2" do
        youtube_monitor = %MonitorItem{url: "http://youtube.com/", action_on_up: nil, action_on_down: nil, keep_history: false}
    
        assert {:ok, {:up, _}} = Monitor.monitor(youtube_monitor)
    end

    test "test url that is down" do
        monitor = %MonitorItem{url: "http://asbdjkasd.com/", action_on_up: nil, action_on_down: nil, keep_history: false}
    
        assert {:ok, {:down, _}} = Monitor.monitor(monitor)
    end 

    test "is it recorded in history" do 
        monitor = %MonitorItem{url: "http://asbdjkasd.com/", action_on_up: nil, action_on_down: nil, keep_history: true}
        
        time_before = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
        
        # to assure time_recorded won't be equal to time_before
        :timer.sleep(100)

        Monitor.monitor(monitor)
        
        
        time_recorded = 
            Amnesia.transaction do 
                History.get_last(monitor.url).time
            end

        assert time_before < time_recorded
    end
end
