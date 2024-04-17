defmodule Example.Poll do
  use GenServer

  alias Example.Lol
  alias Example.Summoner

  def start_link(%Summoner{} = summoner, session) do
    case GenServer.start_link(__MODULE__, %{
           summoner: summoner,
           session: session,
           participants: []
         }) do
      {:ok, pid} ->
        schedule_next_ping(pid)
        {:ok, pid}

      error ->
        error
    end
  end

  def ping(pid) do
    result = GenServer.call(pid, :ping)
    schedule_next_ping(pid)
    result
  end

  defp schedule_next_ping(pid) do
    Process.send_after(pid, :ping, :timer.minutes(1))
  end

  @impl true
  def init(summoner) do
    {:ok, summoner}
  end

  @impl true
  def handle_info(:ping, %{summoner: %{name: name}, session: session} = state) do
    next_participants = Lol.recent_summoner_participants(session, name)
    {:noreply, %{state | participants: next_participants}}
  end

  @impl true
  def handle_call(:ping, _from, state) do
    {:reply, state, state}
  end
end
