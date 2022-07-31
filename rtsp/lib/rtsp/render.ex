defmodule Rtsp.Render do

  @spec render(Rtsp.Data) :: binary
  def render(data) do
    EEx.eval_file("../www/template.html.eex",
      [
        data: data,
      ])
  end

end
