require('computer_player')
require('player')
require('rspec')
require('playing_card')

describe(ComputerPlayer) do
  let(:computer_player) { ComputerPlayer.new('Larry') }
  let(:ranks) { %w[Ace King Queen] }
  let(:cards) { ranks.map { |rank| PlayingCard.new(rank: rank) } }
  let(:add_cards_to_computer) { computer_player.add_cards(cards) }

  it('can have a name') do
    expect(computer_player.name).to eq('Larry')
  end

  it('use inherited methods from player class') do
    add_cards_to_computer
    expect(computer_player.empty?).to be(false)
  end

  it('#pick_random_rank') do
    add_cards_to_computer
    expect(ranks.include?(computer_player.pick_random_rank)).to be(true)
  end
end
