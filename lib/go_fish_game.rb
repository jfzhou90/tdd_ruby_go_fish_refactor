require('./lib/deck')
require('./lib/player')

class GoFishGame
  attr_reader :deck, :players, :started, :winner

  def initialize(deck: CardDeck.new)
    @deck = deck
    @players = []
    @round = 0
    @started = false
    @winner = nil
  end

  def add_players(player)
    player.is_a?(Array) ? players.concat(player) : players.push(player)
  end

  def current_player
    players[round % players.count]
  end

  def any_winner?
    players.any?(&:empty?) ? self.winner = highest_score_player : false
  end

  private

  attr_accessor :round
  attr_writer :winner

  def go_to_next_player
    self.round = round + 1
  end

  def distribute_cards_to_players
    deck.shuffle
    init_cards_count = players.count > 3 ? 5 : 7
    init_cards_count.times do
      players.each { |player| player.add_cards(deck.deal) }
    end
  end

  def highest_score_player
    players.max_by(&:points)
  end

  def transfer_cards(player, rank)
    current_player.add_cards(player.give(rank))
  end

  def go_fish(rank)
    card = deck.deal
    current_player.add_cards(card)
    go_to_next_player unless card.rank.casecmp(rank).zero?
  end
end
