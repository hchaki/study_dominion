require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "end_turn! で手番が次のプレイヤーに移り、一周して戻る" do
    game = Game.create!(status: :playing, turn_phase: :action, actions_remaining: 1, buys_remaining: 1, coins: 0)
    p1 = Player.create!(name: "P1")
    p2 = Player.create!(name: "P2")
    gp1 = game.game_players.create!(player: p1, seat_order: 0)
    gp2 = game.game_players.create!(player: p2, seat_order: 1)
    game.turns.create!(number: 1, game_player: gp1)

    assert_equal gp1, game.current_game_player
    game.end_turn!
    assert_equal gp2, game.current_game_player
    game.end_turn!
    assert_equal gp1, game.current_game_player  # 一周して先頭に戻る
  end

  test "play_cpu_turns! は CPU の手番を自動で消化して人間に手番を戻す" do
    game = Game.create!(status: :playing, turn_phase: :action, actions_remaining: 1, buys_remaining: 1, coins: 0)
    human = game.game_players.create!(player: Player.create!(name: "H"), seat_order: 0, cpu: false)
    cpu = game.game_players.create!(player: Player.create!(name: "C"), seat_order: 1, cpu: true)
    game.turns.create!(number: 1, game_player: human)
    # game_over? が false になるよう属州をサプライに1枚置く
    game.game_cards.create!(card: Card.create!(name: "属州", cost: 8), place: :supply, position: 0)

    game.end_turn!            # 人間の番を終える → CPU の番へ
    assert_equal cpu, game.current_game_player
    game.play_cpu_turns!      # CPU が自動でプレイ → 人間に戻る
    assert_equal human, game.current_game_player
  end
end
