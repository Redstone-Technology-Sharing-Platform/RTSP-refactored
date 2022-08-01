defmodule Rtsp.Router do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Static,
    at: "/",
    from: "../www",
    only: ["assets", "xincs", "robots.txt", "sponsor.html"]

  plug :match
  plug :dispatch

  forward "/technical_survival", to: Rtsp.RenderRouter

  get "/" do
    page = File.read!("../www/index.html.eex")
    send_resp(conn, 200, page)
  end


  match _ do
    send_resp(conn, 404, "404 Not Found\nYou Muffin Head")
  end
end
