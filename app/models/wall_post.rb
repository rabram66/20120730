# Facebook wall post
class WallPost

  FEED_URL = "http://www.facebook.com/feeds/page.php?format=json&id=%s"

  attr_accessor :text, :facebook_post_url, :author_name
  
  def initialize(attrs={})
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end

  class << self

    def latest(facebook_id)
      posts = feed(facebook_id,1)
      posts.first unless posts.blank?
    end

    def feed(facebook_id,count=10)
      FacebookApi.feed(facebook_id,count) do |entry|
        WallPost.new( 
          :text              => entry['title'].strip, 
          :facebook_post_url => entry['alternate'],
          :author_name       => entry['author']['name']
        )
      end
    end

  end

end