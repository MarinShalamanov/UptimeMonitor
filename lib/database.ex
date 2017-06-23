use Amnesia

# defines a database called Database, it's basically a defmodule with
# some additional magic
defdatabase UptimeMonitor.Database do
  
  deftable MonitorItem, [:url, :action_on_up, :action_on_down, :keep_history, :time_interval], type: :bag do
    
  end

  deftable History, [:url, :time, :status], type: :bag, index: [:time] do
    def add_entry ({status, _item = %MonitorItem{url: url} }) do 
        en = %History{
            url: url, 
            time: :os.system_time(:millisecond), 
            status: status
        } 
        
        en |> History.write    
    end

    def last_state_of (_url) do
        :unknown
    end


    def get (:all) do 
        History.stream |> Enum.to_list 
    end

    def get (url) do 
        History.read(url) || []
    end
    
    def get_last (url) do
        get(url) 
        |> Enum.sort_by(fn x -> x.time end, &>=/2)
        |> Enum.at(0)
    end
  end

end