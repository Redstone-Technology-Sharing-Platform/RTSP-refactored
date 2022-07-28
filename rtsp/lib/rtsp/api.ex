defmodule Rtsp.Api do
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:urlencoded]
  plug :match
  plug :dispatch

  match _ do
    send_resp conn, 501, "Not implemented"
  end

end
