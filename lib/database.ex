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

    @doc """
    Returns all history (for all monitors).
    """
    def get (:all) do 
        History.stream |> Enum.to_list 
    end
    
    @doc """
    Returns all history items for the given url.
    """
    def get (url) do 
        History.read(url) || []
    end
    
    @doc """
    Returns the last (most recent) history item for the given url
    """
    @spec get_last(String.t) :: History.t
    def get_last(url) do
        get(url) 
        |> Enum.sort_by(fn x -> x.time end, &>=/2)
        |> Enum.at(0)
    end
    
    @doc """
    Returns the last state of the given url or :unknown if no monitoring is done yet.
    """
    @spec get_last_state(String.t) :: UptimeMonitor.Core.Monitor.url_status
    def get_last_state (url) do
        last_history_item = get_last(url)
        case last_history_item do 
            nil -> :unknown
            _ -> last_history_item.status
        end
    end
  end

end