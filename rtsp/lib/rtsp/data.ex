defmodule Rtsp.Data do
  defstruct [:name, :title, :description, :image, list: []]

  @data_path "../data/"

  def list(path) do
    expand_path = @data_path <> path <> ".json"
    if File.exists?(expand_path) do
      content = File.read!(expand_path)
      case Poison.decode(content, [as: Rtsp.Data, keys: :atoms]) do
        {:ok, _} = decoded -> decoded
        {:error, _} = error -> error
      end
    else
      {:error, :notfound}
    end
  end

  def list(path_1, path_2) do
  end

  def videos(path_1, path_2) do
  end

end
