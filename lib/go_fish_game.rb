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

  def start
    distribute_cards_to_players
  end

  def add_players(player)
    player.is_a?(Array) ? players.concat(player) : players.push(player)
  end

  def current_player
    winner ? nil : players[round % players.count]
  end

  def any_winner?
    players.any?(&:empty?) ? self.winner = highest_score_player : false
  end

  def play_round(player_name, rank)
    player = find_player(player_name)
    player.any_rank?(rank) ? transfer_cards(player, rank) : go_fish(rank)
    current_player.check_complete
  end

  def other_players(current_user)
    players.reject { |player| player.name == current_user.name }
  end

  def find_player(name)
    players.find { |player| player.name.casecmp(name).zero? }
  end

  private

  attr_accessor :round
  attr_writer :winner

  def requested_player(player); end

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
