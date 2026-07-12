class GamesController < ApplicationController
  def new
    # 新規ゲーム開始ボタンを表示するだけ(ビューは空でOK)
  end

  def create
    player = Player.first || Player.create!(name: "あなた")
    game = Game.setup!(player: player)
    redirect_to game
  end

  def show
    @game = Game.find(params[:id])
    @game_player = @game.game_players.first
    # サプライを {カード => 残りgame_cards} にまとめる(card_kinds も一緒に読んで N+1 を防ぐ)
    @supplies = @game.game_cards.supply.includes(card: :card_kinds).group_by(&:card)
  end

  def play_treasures
    game = Game.find(params[:id])
    game.game_players.first.play_all_treasures!
    redirect_to game
  end

  def play_action
    game = Game.find(params[:id])
    game_player = game.game_players.first
    game_card = game.game_cards.find(params[:game_card_id])
    targets = game_player.game_cards.where(id: params[:target_ids]).to_a
    game_player.play_action!(game_card, targets: targets)
    redirect_to game
  end

  def buy
    game = Game.find(params[:id])
    card = Card.find(params[:card_id])
    game.game_players.first.buy!(card)
    redirect_to game
  end

  def end_turn
    game = Game.find(params[:id])
    game.game_players.first.cleanup!
    redirect_to game
  end

  def to_buy_phase
    game = Game.find(params[:id])
    game.update!(turn_phase: :buy)
    redirect_to game
  end
end