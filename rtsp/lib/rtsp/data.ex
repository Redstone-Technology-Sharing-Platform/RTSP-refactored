defmodule Rtsp.Data do
  defstruct [:title, :description, :path, list: [], sidebar: []]
  alias Rtsp.Data

  @basic_path "technical_survival/"
  @data_path "../data/"
  @image_path "section_icons/"
  @bv_image_path "bilibili/"
  @bilibili "https://bilibili.com/"
  @toplevel_title "技术向生存分类"

  @spec toplevel() :: {:ok, Data} | {:error, term}
  def toplevel() do
    content = parse_toplevel()
    data =
      %Data{
        title: @toplevel_title,
        description: @toplevel_title,
        sidebar: %{top: @toplevel_title, list: parse_toplevel()},
        list: content
        |> Enum.map(fn obj ->
          %{
            "title" => obj.title,
            "description" => obj.description,
            path: @basic_path <> obj.path,
            image: @image_path <> obj.path <> ".jpg"}
        end)
      }
    {:ok, data}
  end

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
            sidebar: %{top: @toplevel_title, list: parse_toplevel()},
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
            description: content_part["description"],
            sidebar: %{
              top: content["title"],
              list:
              Map.keys(content) -- ["title", "description"]
              |> Enum.map(fn key ->
                %{path: key, title: content[key]["title"]}
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
                description: content_part["description"],
                sidebar: %{
                  top: content_path_1["title"],
                  list:
                  Map.keys(content_path_1) -- ["title", "description"]
                  |> Enum.map(fn key ->
                    %{path: key, title: content_path_1[key]["title"]}
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

  def generate_toplevel_file() do
    {:ok, toplevel_file} = Path.wildcard(@data_path <> "*.toml")
    |> Enum.map(fn file -> {
      String.replace(file, ".toml", "") |> String.replace(@data_path, ""),
      Toml.decode_file!(file)}
    end)
    |> Enum.filter(fn {_path, decoded} -> decoded["title"] != nil end)
    |> Enum.map(fn {path, decoded} -> %{path: path, title: decoded["title"], description: decoded["description"]} end)
    |> Poison.encode()
    File.write(@data_path <> "toplevel.json", toplevel_file)
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
    Poison.decode!(File.read!(expand_path), %{keys: :atoms})
  end

  defp get_bv_info(bv) do
    case GenServer.call(:db, {:query, bv}) do
      {:ok, title, author} ->
        {title, author}
      msg -> IO.inspect msg
    end
  end
end
