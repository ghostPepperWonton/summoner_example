defmodule Example.Poll do
  use GenServer

  alias Example.Lol
  alias Example.Session
  alias Example.Summoner

  @spec start_link(session :: Session.t(), summoner :: Summoner.t()) ::
          GenServer.on_start()
  def start_link(%Session{} = session, %Summoner{} = summoner) do
    GenServer.start_link(__MODULE__, %{
      summoner: summoner,
      session: session,
      participants: [],
      matches: [],
      count: 0,
      timer: nil
    })
  end

  defp schedule_next_ping do
    Process.send_after(self(), :ping, :timer.minutes(1))
  end

  @impl true
  def init(%{summoner: %{name: name}, session: session} = state) do
    timer = schedule_next_ping()

    matches =
      case Lol.recent_matches(session, name) do
        {:ok, matches} -> matches
        _ -> []
      end

    participants =
      case Lol.recent_summoner_participants(session, name) do
        {:ok, participants} -> participants
        _ -> []
      end

    {:ok,
     %{
       state
       | participants: participants,
         matches: matches,
         timer: timer
     }}
  end

  @impl true
  def handle_info(
        :ping,
        %{
          summoner: %{name: name},
          session: session,
          participants: participants,
          matches: matches,
          count: count,
          timer: timer
        } = state
      ) do
    next_timer =
      if count >= 60 do
        Process.cancel_timer(timer)
        nil
      else
        timer
      end

    {:noreply,
     %{
       state
       | participants: get_next_participants(session, name, participants),
         matches: get_next_matches(session, name, matches),
         count: count + 1,
         timer: next_timer
     }}
  end

  defp get_next_matches(session, name, matches) do
    case Lol.recent_matches(session, name) do
      {:ok, next_matches} ->
        next_matches
        |> Enum.filter(&(!(&1 in matches)))
        |> Enum.each(&IO.puts("Summoner #{name} completed match #{&1}"))

        next_matches

      _ ->
        matches
    end
  end

  defp get_next_participants(session, name, participants) do
    case Lol.recent_summoner_participants(session, name) do
      {:ok, next_participants} -> next_participants
      _ -> participants
    end
  end
end
