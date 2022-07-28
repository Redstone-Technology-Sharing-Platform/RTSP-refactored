defmodule Rtsp.Render do

  def render(section_title, number) do
    EEx.eval_file("../www/template.html.eex", [section_title: section_title, n: number])
  end

end
