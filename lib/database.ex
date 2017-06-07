use Amnesia

# defines a database called Database, it's basically a defmodule with
# some additional magic
defdatabase UptimeMonitor.Database do
  
  deftable MonitorItem, [:url, :action_on_up, :action_on_down, :keep_history], type: :bag do
    
  end

  deftable History, [:url, :time, :status], type: :bag, index: [:time] do
    def add_entry ({status, _item = %MonitorItem{url: url} }) do 
        %History{
            url: url, 
            time: :os.system_time(:millisecond), 
            status: status
        } 
        |> History.write    
    end

    def last_state_of (_url) do
        :unknown
    end

  end

end