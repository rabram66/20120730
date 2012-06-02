module DatedModel
  def happening_now?
    date = Date.today
    if start_date && end_date
      date >= start_date.to_date && date <= end_date.to_date
    elsif start_date
      date >= start_date.to_date
    elsif end_date
      date <= end_date.to_date
    else
      true # if no start/end, assume it's happening now
    end
  end

  def coming_soon?
    !happening_now?
  end
end