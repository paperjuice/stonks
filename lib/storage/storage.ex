defmodule Stonks.Storage do
  @moduledoc false

  alias :dets, as: Dets

  require Logger

  use GenServer

  # Callbacks

  def start_link(_) do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    Dets.open_file(:disk_storage, type: :set)
  end

  def get_item(key) do
    GenServer.call(__MODULE__, {:get, key}, 10_000)
  end

  def insert_item(value) do
    GenServer.call(__MODULE__, {:insert, value}, 10_000)
  end

  # ---------------------------------------------
  #                   CALLBACKS
  # ---------------------------------------------
  @impl true
  def handle_call({:get, key}, _from, table) do
    value = Dets.lookup(table, key)
    {:reply, value, table}
  end

  @impl true
  def handle_call({:insert, value}, _from, table) do
    key = Nanoid.generate()

    case Dets.insert_new(table, {key, value}) do
      true -> {:reply, {:ok, key}, table}
      _ -> {:reply, {:error, "#{value} could not be inserted"}, table}
    end
  end

  @impl true
  def handle_info({:EXIT, _from, reason}, table) do
    Logger.info("exiting")
    Dets.close(table)
    # see GenServer docs for other return types
    {:stop, reason, table}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, table) do
    Logger.info("exiting with DOWN")
    Dets.close(table)
    {:noreply, table}
  end
end
