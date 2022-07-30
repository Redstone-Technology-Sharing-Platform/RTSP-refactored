defmodule Rtsp.Data do

  @data_path "../data/"

  def list(path) do
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

  def videos(path_1, path_2) do
  end

end
