defmodule Economancy.Data.GameState do
  defstruct day: 1, phase: nil, shop: %{}, players: [], player: 0
end

defmodule Economancy.Data.Phase do
  defstruct name: "investing", attacker: nil, attacker_card: nil, winner: nil

  def is_attacking?(phase) do
    phase.name == "attacking"
  end
end

defmodule Economancy.Data.Player do
  defstruct coins: 0, buys: 0, cards: []
end

defmodule Economancy.Data.Card do
  defstruct name: nil, uses: 0

  def can_defend?(%Economancy.Data.Card{uses: 0}), do: true
  def can_defend?(%Economancy.Data.Card{uses: 1, name: "Wall of Wealth"}), do: true
  def can_defend?(_), do: false
  def can_attack?(%Economancy.Data.Card{uses: 0}), do: true
  def can_attack?(_), do: false

  # Not included in the shop
  # def cost(%Economancy.Data.Card{name: "Sorcerer's Stipend"}), do: 0
  def cost(%Economancy.Data.Card{name: "Board of Monopoly"}), do: 0
  def cost(%Economancy.Data.Card{name: "Incantation"}), do: 0
  def cost(%Economancy.Data.Card{name: "Worker"}), do: 0
  def cost(%Economancy.Data.Card{name: "Magic Bean Stock"}), do: 0
  def cost(%Economancy.Data.Card{name: "Bubble"}), do: 0
  def cost(%Economancy.Data.Card{name: "Ghost"}), do: 0
  def cost(%Economancy.Data.Card{name: "Senior Worker"}), do: 0
  def cost(%Economancy.Data.Card{name: "Gold Fish"}), do: 0
end

defmodule Economancy.Data do
  alias Economancy.Data.{GameState, Phase, Player, Card}

  def deserialize_game_state(json) do
    with {:ok, game_state_map} <- Jason.decode(json),
         {:ok, game_state} <- structure_game_state(game_state_map) do
      {:ok, game_state}
    else
      {:error, reason} -> {:error, "JSON Decoding Failed: #{reason}"}
    end
  end

  defp structure_game_state(game_state_map) do
    with %{
           "day" => day,
           "phase" => phase_map,
           "shop" => shop,
           "players" => players,
           "player" => player
         } <- game_state_map,
         {:ok, phase} <- structure_phase(phase_map),
         players <- structure_players(players) do
      {:ok, %GameState{day: day, phase: phase, shop: shop, players: players, player: player}}
    else
      {:error, reason} -> {:error, "Game State Structuring Failed: #{reason}"}
    end
  end

  defp structure_phase(phase_map) do
    case phase_map do
      %{"name" => "investing"} ->
        {:ok, %Phase{name: "investing"}}

      %{"name" => "attacking", "attacker" => attacker, "attacker_card" => attacker_card} ->
        {:ok, %Phase{name: "attacking", attacker: attacker, attacker_card: attacker_card}}

      %{"name" => "buy"} ->
        {:ok, %Phase{name: "buy"}}

      %{"name" => "end", "winner" => winner} ->
        {:ok, %Phase{name: "end", winner: winner}}

      _ ->
        {:error, "Invalid Phase"}
    end
  end

  defp structure_players(players) do
    Enum.reduce_while(players, [], fn
      %{"coins" => coins, "buys" => buys, "cards" => cards}, acc ->
        with cards <- structure_cards(cards) do
          {:cont, [%Player{coins: coins, buys: buys, cards: cards} | acc]}
        else
          {:error, reason} -> {:halt, {:error, "Player Structuring Failed: #{reason}"}}
        end

      _, _ ->
        {:halt, {:error, "Player Structuring Failed"}}
    end)
  end

  defp structure_cards(cards) do
    Enum.reduce_while(cards, [], fn
      %{"name" => name, "uses" => uses}, acc ->
        {:cont, [%Card{name: name, uses: uses} | acc]}

      _, _ ->
        {:halt, {:error, "Card Structuring Failed"}}
    end)
  end
end
