defmodule Rtsp.Crawler.DB do
  def init_db() do
    :mnesia.create_table(BiliBili, [attributes:
                                    [:bv, :title, :author, :image],
                                    disc_copies: [node()]  # save to disk
                                   ])
  end
end
