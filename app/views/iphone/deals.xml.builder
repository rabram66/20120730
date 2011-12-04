xml.instruct!
xml.Result do |r|
  r.Deals do |deals|
    @deals.each do |deal|
      deals.Deal do |elem|
        elem.title deal.title
        elem.link deal.url
      end
    end
  end
end
