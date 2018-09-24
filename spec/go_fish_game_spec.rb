require('rspec')
require('go_fish_game')
require('deck')
require('playing_card')
require('player')

describe(GoFishGame) do
  let(:game) { GoFishGame.new }
  let(:player) { Player.new(name: 'Joey') }
  let(:player2) { Player.new(name: 'Roy') }
  let(:players) { [Player.new, Player.new, Player.new, Player.new] }
  let(:set) { [PlayingCard.new, PlayingCard.new, PlayingCard.new, PlayingCard.new] }

  describe('#add_player') do
    it('allows user to join a game') do
      game.add_players(player)
      expect(game.players.count).to be(1)
      game.add_players(player)
      expect(game.players.count).to be(2)
    end

    it('allows a group of users(array) to join the same game') do
      game.add_players(players)
      expect(game.players.count).to be(4)
    end
  end

  describe('#distribute_cards_to_players') do
    it('gives the correct number of cards in a 2 player game') do
      game.add_players(player)
      game.add_players(player2)
      game.send(:distribute_cards_to_players)
      expect(game.players.map(&:cards_left).all?(7)).to be(true)
    end

    it('gives the correct number of cards in a 4 player game') do
      game.add_players(players)
      game.send(:distribute_cards_to_players)
      expect(game.players.map(&:cards_left).all?(5)).to be(true)
    end
  end

  describe('#go_to_next_player') do
    it('allows the game to proceed to the next player') do
      expect(game.send(:round)).to be(0)
      game.send(:go_to_next_player)
      expect(game.send(:round)).to be(1)
    end
  end

  describe('#current_player') do
    it('returns the correct current player each round') do
      game.add_players(player)
      game.add_players(player2)
      expect(game.current_player.name).to eq('Joey')
      game.send(:go_to_next_player)
      expect(game.current_player.name).to eq('Roy')
    end
  end

  describe('#highest_score_player') do
    it('returns the player with highest points and set to winner') do
      game.add_players([player, player2])
      player2.add_cards(set)
      player2.check_complete
      expect(game.send(:highest_score_player)).to_not eq(player)
      expect(game.send(:highest_score_player)).to eq(player2)
    end
  end

  describe('#any_winner?') do
    it('sets the highest score player to winner.') do
      game.add_players([player, player2])
      player2.add_cards(set)
      player2.check_complete
      game.any_winner?
      expect(game.winner).to_not be(player)
      expect(game.winner).to be(player2)
    end
  end
end
