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
end
