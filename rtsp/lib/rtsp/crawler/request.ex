defmodule Rtsp.Crawler.Request do
  @api "http://api.bilibili.com/x/web-interface/view?bvid="


  def get_data(bv) do
    json = HTTPoison.get!(@api <> bv).body |> Poison.decode
    case json do
      {:error, _} = error -> error
      {:ok, decoded} ->
        case decoded["code"] do
          0 ->
            title  = decoded["data"]["title"]         |> IO.inspect
            author = decoded["data"]["owner"]["name"] |> IO.inspect
            image_url = decoded["data"]["pic"]
            :ok = File.write("../www/assets/images/bilibili/#{bv}.jpg",
              HTTPoison.get!(image_url).body)
            {:ok, title, author}
          status_code -> {:error, status_code}
        end
    end
  end

end
