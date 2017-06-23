use Amnesia

defmodule UptimeMonitor.AdminPanel.Router do
    use Plug.Router
    @moduledoc """
    Handles all requests for the admin panel.
    """
    
    alias UptimeMonitor.Database.MonitorItem
    alias UptimeMonitor.Configuration
    alias UptimeMonitor.Core.Action
    
    require Logger
    
    plug Plug.Static,
        at: "/public",
        from: "priv/static/"
    
    plug Plug.Parsers, parsers: [:urlencoded, :json]
    
    plug :match
    plug :dispatch
    
    get "/", do: send_resp(conn, 200, "Welcome")

    post "api/add_monitor" do
        Logger.info("add " <> inspect(conn))
        
        monitor = %MonitorItem{
            url: conn.params["url"],
            time_interval: get_time_interval(conn),
            action_on_up: get_action_up(conn), 
            action_on_down: get_action_down(conn), 
            keep_history: get_history(conn)} 
        |> validate

        send_resp(conn, 
            200, 
            monitor |> Configuration.add_monitor |> inspect )
    end

    get "api/remove_monitor" do
        url = conn.params["url"]

        case (url |> Configuration.remove_monitor) do 
            :ok -> send_resp(conn, 200, url)
            _ -> send_resp(conn, 500, "An error occured")
        end
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
            Map.get(conn.params, "url", :all)
            |> Configuration.get_history
            |> Enum.map(fn(x) -> 
                new_time = x.time 
                    |> DateTime.from_unix!(:millisecond)
                    |> DateTime.to_string

                %{x | :time => new_time}
                end
                )
            |> Poison.encode!
            
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, response)
    end

    match _, do: send_resp(conn, 404, "Oops!")

    defp get_action_up(conn) do
        case conn.params["action_up"] do
            "none" -> %Action{type: :none}
            "httpcall" ->%Action{type: :httpcall, attributes: [conn.params["url_up"]]}
        end
    end

    defp get_action_down(conn) do
        case conn.params["action_down"] do
            "none" -> %Action{type: :none}
            "httpcall" ->%Action{type: :httpcall, attributes: [conn.params["url_down"]]}
        end
    end

    defp get_history(conn) do 
        case Map.get(conn.params, "history", nil) do 
            nil -> false
            _ -> true
        end
    end 
    
    defp get_time_interval(conn) do
        {res, _} = conn.params["interval"] |> Integer.parse
        res
    end
    
    defp validate(%MonitorItem{time_interval: t}) 
        when t < 1, do: raise "time interval should be positive" 
    
    defp validate(monitor), do: monitor

end