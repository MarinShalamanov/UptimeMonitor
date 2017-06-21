defmodule UptimeMonitor.Monitor do
    
    alias UptimeMonitor.Database.MonitorItem;
    alias UptimeMonitor.Database.History;
    alias UptimeMonitor.Action;
    
    use Amnesia
    
    @type monitor_status :: :ok | :error
    @type url_status :: :up | :down | :unknown
    
    @spec monitor(MonitorItem) :: {monitor_status, {url_status, MonitorItem}}
    def monitor(item) do 
        status = item |> check
        
        status |> write_to_db
        status |> take_action_if_needed
        
        {:ok, status}
    end
    
    @spec check(MonitorItem) :: {url_status, MonitorItem}
    defp check(item = %MonitorItem{url: url}) do
        status = url 
            |> HTTPotion.get
            |> HTTPotion.Response.success?
            |> to_up_down_atom
        
        {status, item}
    end
    
    defp to_up_down_atom(_up = true), do: :up
    defp to_up_down_atom(_up = false), do: :down
    
    defp write_to_db({_, %MonitorItem{keep_history: false}}), do: :ok
        
    defp write_to_db(history_item) do
        Amnesia.transaction do
            history_item |> History.add_entry
        end
        
        :ok
    end
        
    defp take_action_if_needed({_status = :up, _item = %MonitorItem{action_on_up: :none}}), do: nil
        
    defp take_action_if_needed({_status = :down, _item = %MonitorItem{action_on_down: :none}}), do: nil
        
    defp take_action_if_needed({state, item}) do 
        
        last_state = Amnesia.transaction do
            History.last_state_of(item.url)
        end
        
        if state != last_state do 
            {state, item} |> get_action_to_take |> Action.take_action
        end 
    end
    
    defp get_action_to_take({_state = :up, item}), do: item.action_on_up
        
    defp get_action_to_take({_state = :down, item}), do: item.action_on_down 
end