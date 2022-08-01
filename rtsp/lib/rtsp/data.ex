defmodule Rtsp.Data do
  defstruct [:title, :path, :description, list: [], sidebar: []]
  alias Rtsp.Data

  @basic_path "./technical_survival/"
  @data_path "../data/"
  @image_path "section_icons/"
  @bv_image_path "bilibili/"
  @bilibili "https://bilibili.com/"

  @spec list(String.t) :: {:ok, Data} | {:error, term}
  # techinal_survival/block_resources
  def list(path) do
    case parse_file(path) do
      {:error, _} = error -> error
      {:ok, content} ->
        data =
          %Data{
            title: content["title"],
            description: content["description"],
            path: path,
            sidebar: %{top: "技术向生存分类", list: parse_toplevel()},
            list: Map.keys(content) -- ["title", "description"]
            |> Enum.map(fn key ->
              # add :path and :image for each obj in list
              Map.put(content[key], :path, @basic_path <> path <> "/" <> key)
              |> Map.put(:image, @image_path <> path <> "/" <> key <> ".jpg")
            end)
        |> IO.inspect()
      }
        {:ok, data}
    end
  end

  @spec list(String.t, String.t) :: {:ok, Data} | {:error, term}
  # techinal_survival/block_resources/tree
  def list(path_1, path_2) do
    case parse_file(path_1) do
      {:error, _} = error -> error
      {:ok, content} ->
        case Map.fetch(content |> IO.inspect, path_2) do
          {:ok, content_part} ->
            data = %Data{
            title: content_part["title"],
            path: path_1 <> "/" <> path_2,
            description: content_part["description"],
            sidebar: %{
              top: content["title"],
              list:
              Map.keys(content) -- ["title", "description"]
              |> Enum.map(fn key ->
                {key, content[key]["title"]}
              end)
            },
            list: Map.keys(content_part) -- ["title", "description"]
            |> Enum.map(fn key ->
              Map.put(content_part[key], :path, @basic_path <> path_1 <> "/" <> path_2 <> "/" <> key)
              |> Map.put(:image, @image_path <> "#{path_1}/#{path_2}/#{key}.jpg")
            end)
            |> IO.inspect()
          }
            {:ok, data}
          :error -> {:error, :notfound}
        end
    end
  end

  @spec videos(String.t, String.t, String.t) :: {:ok, Data} | {:error, term}
  # techinal_survival/block_resources/tree/big_sprouce
  def videos(path_1, path_2, path_3) do
    case parse_file(path_1) do
      {:error, _} = error -> error
      {:ok, content} ->
        case Map.fetch(content, path_2) do
          :error -> {:error, :notfound}
          {:ok, content_path_1} ->
            case Map.fetch(content_path_1, path_3) do
              :error -> {:error, :notfound}
              {:ok, content_part} ->
                data = %Data{
                title: content_part["title"],
                path: path_1 <> "/" <> path_2 <> "/" <> path_3,
                description: content_part["description"],
                sidebar: %{
                  top: content_path_1["title"],
                  list:
                  Map.keys(content_path_1) -- ["title", "description"]
                  |> Enum.map(fn key ->
                    {key, content_path_1[key]["title"]}
                  end)
                },
                list: content_part["videos"]
                |> IO.inspect
                |> Enum.map(fn bv ->
                  {v_title, v_author} = get_bv_info(bv)
                  %{
                    "description" => v_author,
                    "title" => v_title,
                    path: @bilibili <> bv,
                    image: @bv_image_path <> bv <> ".jpg",
                    }
                end)
                |> IO.inspect()
              }
                {:ok, data}
            end
        end
    end
  end


  defp parse_file(path) do
    expand_path = @data_path <> path <> ".toml"
    if File.exists?(expand_path) do
      # content = File.read!(expand_path)
      case Toml.decode_file(expand_path) do
        {:ok, _} = decoded -> decoded
        {:error, _} = error -> error
      end
    else
      {:error, :notfound}
    end
  end

  defp parse_toplevel() do
    expand_path = @data_path <> "toplevel.json"
    Poison.decode!(File.read!(expand_path))
    |> Map.to_list()
  end

  defp get_bv_info(bv) do
    case GenServer.call(:db, {:query, bv}) do
      {:ok, title, author} ->
        {title, author}
      msg -> IO.inspect msg
    end
  end
end
