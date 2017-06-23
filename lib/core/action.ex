defmodule UptimeMonitor.Core.Action do
    
    defstruct type: :none, attributes: []
    
    alias UptimeMonitor.Core.Action
    
    
    @type action_type :: :none | :httpcall
    @type t :: %Action{type: action_type}
    
    @spec take_action(t) :: :ok | :error
    def take_action(%Action{type: :none}), do: :ok
        
    def take_action(%Action{type: :httpcall, attributes: [url]}) do
        HTTPotion.get (url)
        
        :ok
    end
    
    def take_action(nil), do: :ok
    
    def take_action(_), do: :error
end