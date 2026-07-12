class GamesController < ApplicationController
  def new
    # 新規ゲーム開始ボタンを表示するだけ(ビューは空でOK)
  end

  def create
    players = [
      Player.find_or_create_by!(name: "プレイヤー1"),
      Player.find_or_create_by!(name: "プレイヤー2"),
    ]
    game = Game.setup!(players: players)
    redirect_to game
  end

  def show
    @game = Game.find(params[:id])
    @game_player = @game.current_game_player
    # サプライを {カード => 残りgame_cards} にまとめる(card_kinds も一緒に読んで N+1 を防ぐ)
    @supplies = @game.game_cards.supply.includes(card: :card_kinds).group_by(&:card)
  end

  def play_treasures
    game = Game.find(params[:id])
    game.current_game_player.play_all_treasures!
    redirect_to game
  end

  def play_action
    game = Game.find(params[:id])
    game_player = game.current_game_player
    game_card = game.game_cards.find(params[:game_card_id])
    targets = game_player.game_cards.where(id: params[:target_ids]).to_a
    game_player.play_action!(game_card, targets: targets)
    redirect_to game
  end

  def buy
    game = Game.find(params[:id])
    card = Card.find(params[:card_id])
    game.current_game_player.buy!(card)
    redirect_to game
  end

  def end_turn
    game = Game.find(params[:id])
    game.end_turn!
    redirect_to game
  end

  def to_buy_phase
    game = Game.find(params[:id])
    game.update!(turn_phase: :buy)
    redirect_to game
  end
end