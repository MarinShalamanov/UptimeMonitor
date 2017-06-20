use Amnesia

defmodule UptimeMonitor.Router do
    use Plug.Router

    alias UptimeMonitor.Database.MonitorItem
    alias UptimeMonitor.Database.History
    alias UptimeMonitor.Configuration
    
    plug Plug.Static,
        at: "/public",
        from: "priv/static/"
    
    plug Plug.Parsers, parsers: [:urlencoded, :json]
    
    plug :match
    plug :dispatch
    
    get "/", do: send_resp(conn, 200, "Welcome")
    get "/test" do
        send_resp(conn, 200, inspect(UptimeMonitor.Monitor.monitor(MonitorItem.read!("https://elixir-lang.org/") |> List.first )))  
    end  



    post "api/add_monitor" do
        monitor = %MonitorItem{url: conn.params["url"], action_on_up: nil, action_on_down: nil, keep_history: true}

        send_resp(conn, 
            200, 
            monitor |> Configuration.add_monitor |> inspect )
    end

    get "api/all_monitors" do
        responce_body = Configuration.all_monitors 
            |> List.flatten 
            |> Poison.encode!

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, responce_body)
    end

    get "api/history" do
        response = 
            Amnesia.transaction do 
                Map.get(conn.params, "url", :all)    
                |> History.get 
                |> List.flatten
                |> Poison.encode!
            end

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, response )
    end

    match _, do: send_resp(conn, 404, "Oops!")
end