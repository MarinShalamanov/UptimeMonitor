use Amnesia

defmodule UptimeMonitor.Router do
    use Plug.Router

    alias UptimeMonitor.Database.MonitorItem
    alias UptimeMonitor.Configuration
    
    plug :match
    plug :dispatch

    get "/", do: send_resp(conn, 200, "Welcome")
    get "/test" do
        send_resp(conn, 200, inspect(MonitorItem.read!("https://github.com/")))  
    end  

    get "/conf" do 
        send_resp(conn, 200, inspect(Configuration.add_monitor))  
    end
    match _, do: send_resp(conn, 404, "Oops!")
end