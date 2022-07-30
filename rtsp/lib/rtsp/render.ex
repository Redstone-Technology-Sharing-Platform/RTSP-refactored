defmodule Rtsp.Render do

  def render(data, path) do
    EEx.eval_file("../www/template.html.eex",
      [
        data: data,
        parent_dir: path
      ])
  end

end
