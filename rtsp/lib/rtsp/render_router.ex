defmodule Rtsp.RenderRouter do
  alias Rtsp.Render
  use Plug.Router

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded]
  plug :match
  plug :dispatch

  get ":path" do
    IO.inspect path
    case Rtsp.Data.list(path) do
      {:ok, data} ->
        page = Render.render(data)
        send_resp(conn, 200, page)
      {:error, error} ->
        send_resp(conn, 404,
          "Not Found: #{inspect(__MODULE__)}\n#{inspect(error)}\n1")
    end
  end

  get ":path_1/:path_2" do
    case Rtsp.Data.list(path_1, path_2) do
      {:ok, data} ->
        page = Render.render(data)
        send_resp(conn, 200, page)
      {:error, error} ->
        send_resp(conn, 404,
          "Not Found: #{inspect(__MODULE__)}\n#{inspect(error)}\n2")
    end
  end

  get ":path_1/:path_2/:path_3" do
    case Rtsp.Data.videos(path_1, path_2, path_3) do
      {:ok, data} ->
        page = Render.render(data)
        send_resp(conn, 200, page)
      {:error, error} ->
        send_resp(conn, 404,
          "Not Found: #{inspect(__MODULE__)}\n#{inspect(error)}\n3")
    end
  end

  match _ do
    send_resp conn, 501, "Not implemented: #{inspect(__MODULE__)}"
  end
end
