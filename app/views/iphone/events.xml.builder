xml.instruct!
xml.Result do |r|
  r.Events do |events|
    @events.each do |event|
      events.Event do |elem|
        elem.name        event.name
        elem.address     event.address
        elem.description event.description
      end
    end
  end
end
