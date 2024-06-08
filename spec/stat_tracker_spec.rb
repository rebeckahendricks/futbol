require 'rspec'
require 'spec_helper'
require './lib/stat_tracker'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe StatTracker do
  it 'exists' do
    game_path = './data/games.csv'
    team_path = './data/teams.csv'
    game_teams_path = './data/game_teams.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    games = CSV.read(locations[:games], headers: true, header_converters: :symbol)
    teams = CSV.read(locations[:teams], headers: true, header_converters: :symbol)
    game_teams = CSV.read(locations[:game_teams], headers: true, header_converters: :symbol)

    stat_tracker = StatTracker.new(games, teams, game_teams)
    expect(stat_tracker).to be_a(StatTracker)
  end

  it 'can read csv files from a locations hash' do
    game_path = './data/games.csv'
    team_path = './data/teams.csv'
    game_teams_path = './data/game_teams.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    stat_tracker = StatTracker.from_csv(locations)

    expect(stat_tracker.games).to be_a(CSV::Table)
    expect(stat_tracker.teams).to be_a(CSV::Table)
    expect(stat_tracker.game_teams).to be_a(CSV::Table)
  end

  describe 'Game Statistics' do
    it 'can calculate the highest total score' do
    end
  end
end
