defmodule UptimeMonitor.Action do
    
    defstruct type: :none, attributes: []
    
    alias UptimeMonitor.Action
    
    def take_action(%Action{type: :none}), do: :ok
    
end