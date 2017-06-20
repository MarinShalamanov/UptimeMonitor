defmodule UptimeMonitor.Action do
    
    defstruct type: :none, attributes: []
    
    alias UptimeMonitor.Action
    
    def take_action(%Action{type: :none}), do: :ok
    
    def take_action(nil), do: :ok
    
end