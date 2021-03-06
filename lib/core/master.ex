use Amnesia 

defmodule UptimeMonitor.Core.Master do 
    use GenServer 
    @moduledoc """
    Spawns and kills workers according to changes in the set
    of the registered monitors, i.e. changes in the database. 
    """
    
    
    alias UptimeMonitor.Core.WorkerSupervisor
    alias UptimeMonitor.Database.MonitorItem
    alias UptimeMonitor.Core.Worker
    
    require Logger
    
    @event_category {:table, MonitorItem, :simple}
    
    def start_link() do
        GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    end
    
    def init(state) do 
        Amnesia.Event.subscribe(@event_category)
        run_workers()
        
        {:ok, state}
    end
    
    def handle_call(_mess, _from, state) do
        {:reply, nil, state}
    end
    
    def handle_cast(_mess, state) do
        {:noreply, state}
    end
    
    def handle_info({:mnesia_table_event, {:write, new_record, _activity_id}}, state) do
        
        new_record
        |> recordToMonitorStruct 
        |> WorkerSupervisor.start_child   
            
        {:noreply, state}
    end
    
    def handle_info({:mnesia_table_event, {:delete, record, _activity_id}}, state) do
        
        {_, url} = record
        
        url
        |> Worker.ref
        |> GenServer.cast(:inactivate)
            
        {:noreply, state}
    end
    
    def handle_info(_mess, state) do 
        {:noreply, state}
    end
    
    def terminate(_reason, _state) do 
        Amnesia.Event.unsubscribe(@event_category)
    end
    
    defp recordToMonitorStruct(record) do
        {_, url, up, down, keep_history, time_int} = record
        
        %MonitorItem{url: url, 
            action_on_up: up, 
            action_on_down: down, 
            keep_history: keep_history, 
            time_interval: time_int}    
    end
    
    defp run_workers do
        Amnesia.transaction do
            MonitorItem.stream 
            |>  Enum.map(fn (x) -> 
                    Enum.map(x, &WorkerSupervisor.start_child/1) 
                    end 
            ) 
        end
    end

end 