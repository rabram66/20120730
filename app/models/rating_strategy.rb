class RatingStrategy

  def initialize
    @points_per_favorite = 10.0
  end

  def rating(location)
    (location.favorites_count / @points_per_favorite).round
  end

end