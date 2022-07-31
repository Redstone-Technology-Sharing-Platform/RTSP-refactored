defmodule Rtsp.Crawler.DB do
  def db_init() do
    :mnesia.create_table(BiliBili, [attributes:
                                    [:bv, :title, :author, :image],
                                    disc_copies: [node()]  # save to disk
                                   ])
  end

  def start() do
    pid = spawn_link(fn -> db_loop() end)
    Process.register(pid, :db)
    :timer.sleep(:infinity)
  end

  def db_loop() do
    receive do
      {:query, from_pid, bv} ->
        IO.puts "query database"
        case db_get_data(bv) do
          {:atomic, []} ->
            db_add(bv)
          {:atomic, [{BiliBili, ^bv, title, author, image}]} ->
            send(from_pid, {:ok, title, author, image})
        end
      msg -> IO.inspect msg
    end
    db_loop()
  end

  def db_get_data(bv) do
    :mnesia.transaction(fn -> :mnesia.read(BiliBili, bv) end)
    |> IO.inspect
  end

  def db_add(bv) do
    case Rtsp.Crawler.Request.get_data(bv) do
      {:error, _} = error -> error
      {:ok, title, author, image} ->
        :mnesia.transaction(fn ->
          :mnesia.write({BiliBili, bv, title, author, image})
        end)
        |> IO.inspect
    end
  end
end
