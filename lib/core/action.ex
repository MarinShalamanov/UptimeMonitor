defmodule UptimeMonitor.Core.Action do
    @moduledoc """
    Represents an action that can be performed according to the monitor's state.
    """
    
    alias UptimeMonitor.Core.Action
    
    defstruct type: :none, attributes: []
    
    @type action_type :: :none | :httpcall
    @type t :: %Action{type: action_type}
    
    @doc """
    Executes the action.
    """
    @spec take_action(t) :: :ok | :error
    def take_action(%Action{type: :none}), do: :ok
        
    def take_action(%Action{type: :httpcall, attributes: [url]}) do
        HTTPotion.get(url)
        :ok
    end
    
    def take_action(nil), do: :ok
    
    def take_action(_), do: :error
end