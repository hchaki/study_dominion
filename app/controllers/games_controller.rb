class GamesController < ApplicationController
  before_action :set_game, only: %i[show play_treasures play_action buy end_turn to_buy_phase]

  def new
    # 新規ゲーム開始ボタンを表示するだけ(ビューは空でOK)
  end

  def create
    game = Game.setup!(participants: [
      { player: Player.find_or_create_by!(name: "あなた"), cpu: false },
      { player: Player.find_or_create_by!(name: "CPU"), cpu: true },
    ])
    redirect_to game
  end

  def show
    @game_player = @game.current_game_player
    # サプライを {カード => 残りgame_cards} にまとめる(card_kinds も一緒に読んで N+1 を防ぐ)
    @supplies = @game.game_cards.supply.includes(card: :card_kinds).group_by(&:card)
  end

  def play_treasures
    @game.current_game_player.play_all_treasures!
    redirect_to @game
  end

  def play_action
    game_player = @game.current_game_player
    game_card = @game.game_cards.find(params[:game_card_id])
    targets = game_player.game_cards.where(id: params[:target_ids]).to_a
    game_player.play_action!(game_card, targets: targets)
    redirect_to @game
  end

  def buy
    card = Card.find(params[:card_id])
    @game.current_game_player.buy!(card)
    redirect_to @game
  end

  def end_turn
    @game.end_turn!
    @game.play_cpu_turns!   # 手番が CPU に移ったら自動でプレイして人間に戻す
    redirect_to @game
  end

  def to_buy_phase
    @game.update!(turn_phase: :buy)
    redirect_to @game
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end
end
