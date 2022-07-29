defmodule Rtsp.Render do

  def render(data) do
    EEx.eval_file("../www/template.html.eex",
      [
        section_title: data.title,
        #description: data.description,
        section_list: data.list,
        parent_dir: data.name
      ])
  end

end
