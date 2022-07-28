defmodule Rtsp.Router do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Static,
    at: "/",
    from: "../www",
    only: ["assets", "xincs", "robots.txt"]

  plug :match
  plug :dispatch

  forward "/api", to: Rtsp.Api

  get "/" do
    page = Rtsp.Render.render("this is a test title", 10)
    send_resp(conn, 200, page)
  end


  match _ do
    send_resp(conn, 404, "404 Not Found\nYou Muffin Head")
  end
end
