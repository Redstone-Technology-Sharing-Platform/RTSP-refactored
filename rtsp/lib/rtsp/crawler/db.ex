defmodule Rtsp.Crawler.DB do
  def db_init() do
    :mnesia.create_table(BiliBili, [attributes:
                                    [:bv, :title, :author],
                                    disc_copies: [node()]  # save to disk
                                   ])
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: :db)
  end


  use GenServer

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:query, bv}, _from, state) do
    case db_get_data(bv) do
      {:atomic, [{BiliBili, ^bv, title, author}]} ->
        {:reply, {:ok, title, author}, state}
      {:atomic, []} ->
        res = db_add(bv)
        {:reply, res, state}
    end
  end

  def db_get_data(bv) do
    :mnesia.transaction(fn -> :mnesia.read(BiliBili, bv) end)
    |> IO.inspect
  end

  def db_add(bv) do
    case Rtsp.Crawler.Request.get_data(bv) do
      {:error, _} = error -> error
      {:ok, title, author} ->
        :mnesia.transaction(fn ->
          :mnesia.write({BiliBili, bv, title, author})
        end)
        |> IO.inspect
        {:ok, title, author}
    end
  end
end
