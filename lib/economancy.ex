defmodule Economancy.CLI do
  def main(_args \\ []) do
    IO.stream(:stdio, :line)
    |> Stream.map(&Economancy.Data.deserialize_game_state/1)
    |> Stream.map(fn {:ok, game_state} -> game_state end)
    |> Stream.map(&Economancy.Player.handle_game_state/1)
    |> Stream.run()
  end
end
