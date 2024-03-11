defmodule Economancy.Player do
  alias Economancy.Data.{Phase, Card}

  def handle_game_state(%{phase: "end"}), do: System.halt(0)
  def handle_game_state(game_state), do: print_move(calc_move(game_state))

  defp print_move(move = [_ | _]), do: IO.puts(Jason.encode!(move))

  defp calc_move(%{phase: %Phase{name: "investing"}} = game_state) do
    invest_random_amount(game_state)
  end

  defp calc_move(%{phase: %Phase{name: "attacking"}} = game_state) do
    attack_or_pass_randomly(game_state)
  end

  defp calc_move(%{phase: %Phase{name: "buy"}} = game_state) do
    buy_random_card(game_state)
  end

  defp invest_random_amount(game_state) do
    coins = Enum.at(game_state.players, game_state.player).coins
    [Enum.random(0..coins)]
  end

  defp attack_or_pass_randomly(game_state) do
    untapped_attack_cards = find_untapped_attackers(game_state)

    case {untapped_attack_cards, Enum.random(0..1)} do
      {[], _} -> [0]
      {_, 0} -> [0]
      {cards, _} -> [Enum.random(cards)]
    end
  end

  defp buy_random_card(game_state) do
    current_coins = Enum.at(game_state.players, game_state.player).coins

    Enum.random(
      ["Pass"] ++
        Enum.filter(game_state.shop, fn {card_name, count} ->
          count > 0 && Card.cost(%Card{name: card_name}) <= current_coins
        end)
    )
  end

  @spec find_untapped_attackers(map()) :: list()
  defp find_untapped_attackers(game_state) do
    my_cards = Enum.at(game_state.players, game_state.player).cards

    my_cards
    |> Enum.filter(&Card.can_attack?(&1))
    |> Enum.map(& &1.name)
  end
end
