defmodule Rtsp.RenderRouter do
  alias Rtsp.Render
  use Plug.Router

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded]
  plug :match
  plug :dispatch

  get ":path" do
    {:ok, data} = Rtsp.Data.list(path)
    page = Render.render(data)
    send_resp(conn, 200, page)
  end

  match _ do
    send_resp conn, 501, "Not implemented: RenderRouter"
  end
end
