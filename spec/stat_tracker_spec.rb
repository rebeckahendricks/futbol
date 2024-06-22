require 'rspec'
require 'spec_helper'
require './lib/stat_tracker'
require 'tempfile'

RSpec.configure do |config|
  config.formatter = :documentation
end

RSpec.describe StatTracker do
  before(:all) do
    @games_file = Tempfile.new(['games', '.csv'])
    @teams_file = Tempfile.new(['teams', '.csv'])
    @game_teams_file = Tempfile.new(['game_teams', '.csv'])

    CSV.open(@games_file.path, 'wb') do |csv|
      csv << %w[game_id season type date_time away_team_id home_team_id away_goals home_goals venue venue_link]
      csv << [1, 20122013, 'Postseason', '5/16/13', 3, 6, 2, 3, 'Toyota Stadium', '/api/v1/venues/null']
      csv << [2, 20132014, 'Regular Season', '3/29/14', 18, 25, 3, 5, 'SeatGeek Stadium', '/api/v1/venues/null']
      csv << [3, 20172018, 'Regular Season', '12/28/17', 17, 1, 3, 3, 'Mercedes-Benz Stadium', '/api/v1/venues/null']
      csv << [4, 20182019, 'Postseason', '5/28/19', 6, 18, 1, 0, 'Heinz Field', '/api/v1/venues/null']
    end

    CSV.open(@teams_file.path, 'wb') do |csv|
      csv << %w[team_id franchiseId teamName abbreviation Stadium link]
      csv << []
    end

    CSV.open(@game_teams_file.path, 'wb') do |csv|
      csv << %w[game_id team_id HoA result settled_in head_coach goals shots tackles pim powerPlayOpportunities powerPlayGoals faceOffWinPercentage giveaways takeaways]
      csv << []
    end

    locations = {
      games: @games_file.path,
      teams: @teams_file.path,
      game_teams: @game_teams_file.path
    }

    @stat_tracker = StatTracker.from_csv(locations)
  end

  after(:all) do
    @games_file.close
    @games_file.unlink
    @teams_file.close
    @teams_file.unlink
    @game_teams_file.close
    @game_teams_file.unlink
  end

  it 'exists' do
    expect(@stat_tracker).to be_a(StatTracker)
  end

  it 'can read csv files from a locations hash' do
    expect(@stat_tracker.games).to be_a(CSV::Table)
    expect(@stat_tracker.teams).to be_a(CSV::Table)
    expect(@stat_tracker.game_teams).to be_a(CSV::Table)
  end

  describe 'Game Statistics' do
    it 'can calculate the highest total score' do
      expect(@stat_tracker.highest_total_score).to eq(8)
    end

    it 'can calculate the lowest total score' do
      expect(@stat_tracker.lowest_total_score).to eq(1)
    end

    it 'can calculate the percentage of home team wins' do
      expect(@stat_tracker.percentage_home_wins).to eq(0.50)
    end

    it 'can calculate the percentage of visitor team wins' do
      expect(@stat_tracker.percentage_visitor_wins).to eq(0.25)
    end

    it 'can calculate the percentage of ties' do
      expect(@stat_tracker.percentage_ties).to eq(0.25)
    end

    it 'can count games by season' do
      expected_hash = { "20122013" => 1, "20132014" => 1, "20172018" => 1, "20182019" => 1 }

      expect(@stat_tracker.count_of_games_by_season).to eq(expected_hash)
    end

    it 'can count the average number of goals per game' do
      expect(@stat_tracker.average_goals_per_game).to eq(5.0)
    end

    it 'can calculate the average number of goals by season' do
      expected_hash = { "20122013" => 5, "20132014" => 8, "20172018" => 6, "20182019" => 1 }

      expect(@stat_tracker.average_goals_by_season).to eq(expected_hash)
    end
  end
end
