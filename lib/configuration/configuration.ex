use Amnesia

defmodule UptimeMonitor.Configuration do
    @moduledoc """
    Provides configurations and information about the system.
    """
    
    require Logger
    
    alias UptimeMonitor.Database.MonitorItem
    alias UptimeMonitor.Database.History
    
    @doc """
    Adds the specified  monitor to the system.
    """
    @spec add_monitor(MonitorItem.t) :: :ok | no_return
    def add_monitor(monitor) do 
        Amnesia.transaction do
            monitor |> MonitorItem.write    
        end
    end
    
    @doc """
    Removes the specified monitor from the system.

    Any workers that do the actual monitoring of this item will be stopped.
    """
    @spec remove_monitor(String.t) :: :ok | no_return
    def remove_monitor(url) do    
        Amnesia.transaction do
            url |> MonitorItem.delete
        end 
    end
    
    @doc """
    Returns a list of all registred monitors.
    """
    @spec all_monitors :: [MonitorItem.t]
    def all_monitors do
        Amnesia.transaction do 
            MonitorItem.stream |> Enum.to_list
        end
    end

    @doc """
    Returns a list of the history for a specified url (if string is passed as argument) 
    or all history (if :all is passed). The returned list is sorted by time in descending 
    oreder (most recent first).
    """
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