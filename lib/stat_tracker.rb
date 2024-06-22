require 'csv'

class StatTracker
  attr_reader :games, :teams, :game_teams

  def initialize(games, teams, game_teams)
    @games = games
    @teams = teams
    @game_teams = game_teams
  end

  def self.from_csv(locations)
    games = CSV.read(locations[:games], headers: true, header_converters: :symbol)
    teams = CSV.read(locations[:teams], headers: true, header_converters: :symbol)
    game_teams = CSV.read(locations[:game_teams], headers: true, header_converters: :symbol)
    new(games, teams, game_teams)
  end

  def total_goals_per_game
    @games.map do |row|
      away_goals = row[:away_goals].to_i
      home_goals = row[:home_goals].to_i
      total_goals = away_goals + home_goals
      { game_id: row[:game_id], total_goals: total_goals }
    end
  end

  def highest_total_score
    highest_scoring_game = total_goals_per_game.max_by { |game| game[:total_goals] }
    highest_scoring_game[:total_goals]
  end

  def lowest_total_score
    lowest_scoring_game = total_goals_per_game.min_by { |game| game[:total_goals] }
    lowest_scoring_game[:total_goals]
  end

  def total_games
    @games.length
  end

  def number_of_home_wins
    @games.count { |game| game[:home_goals].to_i > game[:away_goals].to_i }
  end

  def number_of_visitor_wins
    @games.count { |game| game[:away_goals].to_i > game[:home_goals].to_i }
  end

  def number_of_ties
    @games.count { |game| game[:away_goals].to_i == game[:home_goals].to_i }
  end

  def percentage_home_wins
    (number_of_home_wins.to_f / total_games).round(2)
  end

  def percentage_visitor_wins
    (number_of_visitor_wins.to_f / total_games).round(2)
  end

  def percentage_ties
    (number_of_ties.to_f / total_games).round(2)
  end

  def count_of_games_by_season
    @games.group_by { |game| game[:season] }.transform_values(&:count)
  end

  def average_goals_per_game
    (total_goals_per_game.sum { |game| game[:total_goals] }.to_f / total_games).round(2)
  end

  def average_goals_by_season
    seasons_hash = @games.group_by { |game| game[:season] }
    seasons_hash.each do |season, season_games|
      total_goals_per_season = season_games.sum do |game|
        game[:away_goals].to_i + game[:home_goals].to_i
      end
      seasons_hash[season] = (total_goals_per_season.to_f / season_games.count).round(2)
    end
  end
end
