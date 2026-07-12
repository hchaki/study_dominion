require "test_helper"

class GamePlayerTest < ActiveSupport::TestCase
  test "draw! は山札が足りないとき捨て札をシャッフルして引く" do
    # Arrange: ゲームとプレイヤー、カードを用意
    game = Game.create!(status: :playing, turn_phase: :action, actions_remaining: 1, buys_remaining: 1, coins: 0)
    player = Player.create!(name: "テスト")
    gp = game.game_players.create!(player: player, seat_order: 0)
    card = Card.create!(name: "銅貨", cost: 0)

    # 山札2枚・捨て札3枚(5枚引くには山札が足りない状況)
    2.times { |i| game.game_cards.create!(card: card, game_player: gp, place: :draw_pile, position: i) }
    3.times { |i| game.game_cards.create!(card: card, game_player: gp, place: :discard_pile, position: i) }

    # Act: 5枚引く(足りない分は捨て札シャッフルで補充されるはず)
    gp.draw!(5)

    # Assert: 手札5枚、山札0、捨て札0
    assert_equal 5, gp.game_cards.hand.count
    assert_equal 0, gp.game_cards.draw_pile.count
    assert_equal 0, gp.game_cards.discard_pile.count
  end

  test "buy! はコストの数だけコインを支払い、購入回数が1減り、サプライから自分の捨て札にカードを1枚購入する" do
    # Arrange: ゲームとプレイヤー、カードを用意
    game = Game.create!(status: :playing, turn_phase: :action, actions_remaining: 1, buys_remaining: 1, coins: 3)
    player = Player.create!(name: "テスト")
    gp = game.game_players.create!(player: player, seat_order: 0)
    silver = Card.create!(name: "銀貨", cost: 3)

    # 銀貨をサプライに入れる
    game.game_cards.create!(card: silver, place: :supply, position: 0)

    # Act: 銀貨の購入
    gp.buy!(silver)

    # Assert: 捨て札に銀貨、購入数0、コイン0
    assert_equal "銀貨", gp.game_cards.discard_pile.first.card.name
    assert_equal 0, game.buys_remaining
    assert_equal 0, game.coins
  end

  test "play_action! (村)はアクションが1→2になり、村が場に出て、+1ドローされる" do
    # Arrange: ゲームとプレイヤー、カードを用意
    game = Game.create!(status: :playing, turn_phase: :action, actions_remaining: 1, buys_remaining: 1, coins: 0)
    player = Player.create!(name: "テスト")
    gp = game.game_players.create!(player: player, seat_order: 0)
    cupper = Card.create!(name: "銅貨", cost: 0)
    village = Card.create!(name: "村", cost: 3)

    # 銅貨を山札、村を手札に置く
    game.game_cards.create!(card: cupper, game_player: gp, place: :draw_pile, position: 0)
action_card = game.game_cards.create!(card: village, game_player: gp, place: :hand, position: 0)

    # Act: 村カードの使用
    gp.play_action!(action_card)

    # Assert: 場に村、手札に銅貨、アクション数2
    assert_equal "村", gp.game_cards.in_play.first.card.name
    assert_equal "銅貨", gp.game_cards.hand.first.card.name
    assert_equal 2, game.actions_remaining
  end

  test "play_all_treasures! の後は play_action! できない" do
    game = Game.create!(status: :playing, turn_phase: :action, actions_remaining: 1, buys_remaining: 1, coins: 0)
    player = Player.create!(name: "テスト")
    gp = game.game_players.create!(player: player, seat_order: 0)
    village = Card.create!(name: "村", cost: 3)
    action_card = game.game_cards.create!(card: village, game_player: gp, place: :hand, position: 0)

    gp.play_all_treasures!   # 購入フェーズに移る

    assert_raises(RuntimeError) { gp.play_action!(action_card) }
  end

  test "play_action! (礼拝堂)は選んだカードを廃棄する" do
    game = Game.create!(status: :playing, turn_phase: :action, actions_remaining: 1, buys_remaining: 1, coins: 0)
    player = Player.create!(name: "テスト")
    gp = game.game_players.create!(player: player, seat_order: 0)
    chapel = Card.create!(name: "礼拝堂", cost: 2)
    estate = Card.create!(name: "屋敷", cost: 2)
    chapel_card = game.game_cards.create!(card: chapel, game_player: gp, place: :hand, position: 0)
    trash_me = game.game_cards.create!(card: estate, game_player: gp, place: :hand, position: 1)

    gp.play_action!(chapel_card, targets: [trash_me])

    assert_equal "trash", trash_me.reload.place
  end
end
