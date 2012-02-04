require 'test_helper'

class EventBriteTest < ActiveSupport::TestCase

  setup do
    @coordinates = Rails.application.config.app.default_coordinates
  end
  
  def stub_api(body)
    stub_request(:get, "https://www.eventbrite.com/json/event_search?app_key=#{Rails.application.config.app.eventbrite_app_key}&latitude=#{@coordinates.first}&longitude=#{@coordinates.last}&within=5").
              with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
              to_return(:status => 200, :body => body, :headers => {})
  end

  context 'geocode search' do

    context 'without events' do
      setup do
        stub_api without_events
      end
      should 'return an empty array' do
        events = EventBrite.geosearch @coordinates
        assert events.empty?
      end
    end
    
    context 'with events' do
      setup do
        stub_api with_events
      end
      should 'return an array of events' do
        events = EventBrite.geosearch @coordinates
        assert !events.empty?, "events should not be empty"
        assert_kind_of EventBrite, events.first
      end
    end

  end

  def without_events
    # GET https://www.eventbrite.com/json/event_search?app_key=FMKOHYNE36ODPTPEDM&latitude=40&longitude=40&within=5
    <<-END.gsub(/^ {6}/, '')
      {
          "events": [],
          "error": {
              "error_type": "Not Found",
              "error_message": "No events found matching the following criteria. [distance=5.00M, lat_lng=40.0/40.0,  ]"
          }
      }
    END
  end

  def with_events
    # GET https://www.eventbrite.com/json/event_search?app_key=FMKOHYNE36ODPTPEDM&latitude=33.7711135&longitude=-84.3667805&within=5
    <<-END.gsub(/^ {6}/, '')
      {
          "events": [
              {
                  "summary": {
                      "total_items": "521",
                      "first_event": 2800356943,
                      "last_event": 2890099365,
                      "filters": {
                          "distance": "5.00M",
                          "lat_lng": "33.7711135/-84.3667805"
                      },
                      "num_showing": 10
                  }
              },
              {
                  "event": {
                      "box_header_text_color": "677479",
                      "link_color": "FFCC00",
                      "box_background_color": "677479",
                      "timezone": "US/Eastern",
                      "box_border_color": "677479",
                      "logo": "http://ebmedia.eventbrite.com/s3-s3/eventlogos/12519633/2800356943-2.jpg",
                      "modified": "2012-01-20 05:37:38",
                      "logo_ssl": "https://ebmedia.eventbrite.com/s3-s3/eventlogos/12519633/2800356943-2.jpg",
                      "repeats": "no"
                  }
              }
          ]
      }
    END
=begin
              {
                  "event": {
                      "box_header_text_color": "677479",
                      "link_color": "FFCC00",
                      "box_background_color": "677479",
                      "timezone": "US/Eastern",
                      "box_border_color": "677479",
                      "logo": "http://ebmedia.eventbrite.com/s3-s3/eventlogos/12519633/2800356943-2.jpg",
                      "organizer": {
                          "url": "http://www.eventbrite.com/org/1847982959",
                          "description": "",
                          "id": 1847982959,
                          "name": "Random Family"
                      },
                      "background_color": "677479",
                      "id": 2800356943,
                      "category": "music,entertainment",
                      "box_header_background_color": "CECBAF",
                      "capacity": 0,
                      "num_attendee_rows": 0,
                      "title": "Floco Torres, StereoMonster & Guests LIVE at The Masquerade",
                      "start_date": "2012-02-10 20:00:00",
                      "status": "Live",
                      "description": "<P>Floco Torres makes his debut on The Masquerade stage as well as bringing along StereoMonster and some guests! This is a night of music you don't want to miss! </P>\r\n<P>Tickets are on sale now! 8$ in advance or 12$ at the door </P>\r\n<P> </P>\r\n<P>We have a limited number of advance tickets right here through Eventbrite! The first 5 will receive a custom made \"Ralph BIGhead\" mixtape from Floco & the second 5 will receive a custom made compilation cd from Floco.</P>\r\n<P>CD's can be picked up at the merch table the night of the show. Hope to see you!</P>",
                      "end_date": "2012-02-11 00:00:00",
                      "tags": "Floco Torres, LIVE, Music, Nightlife, Atlanta, Georgia, Fun, ",
                      "text_color": "FFCC00",
                      "title_text_color": "",
                      "tickets": [
                          {
                              "ticket": {
                                  "description": "",
                                  "end_date": "2012-02-10 19:00:00",
                                  "min": 0,
                                  "max": 0,
                                  "price": "9.19",
                                  "visible": "true",
                                  "currency": "USD",
                                  "type": 0,
                                  "id": 12709789,
                                  "name": "Floco Torres w/ StereoMonster "
                              }
                          }
                      ],
                      "distance": "0.11M",
                      "created": "2012-01-18 10:33:53",
                      "url": "http://www.eventbrite.com/event/2800356943",
                      "box_text_color": "CECBAF",
                      "privacy": "Public",
                      "venue": {
                          "city": "Atlanta",
                          "name": "The Masquerade",
                          "country": "United States",
                          "region": "GA",
                          "longitude": -84.364801,
                          "postal_code": "30308",
                          "address_2": "",
                          "address": "695 North Ave",
                          "latitude": 33.771038,
                          "country_code": "US",
                          "id": 1583019,
                          "Lat-Long": "33.771038 / -84.364801"
                      },
                      "modified": "2012-01-20 05:37:38",
                      "logo_ssl": "https://ebmedia.eventbrite.com/s3-s3/eventlogos/12519633/2800356943-2.jpg",
                      "repeats": "no"
                  }
              },
              {
                  "event": {
                      "box_header_text_color": "677479",
                      "link_color": "FFCC00",
                      "box_background_color": "677479",
                      "timezone": "US/Eastern",
                      "box_border_color": "677479",
                      "logo": "http://ebmedia.eventbrite.com/s3-s3/eventlogos/71025/994922841-1.jpg",
                      "organizer": {
                          "url": "http://ikemacs.eventbrite.com",
                          "description": "Where Dance & Fitness Meets...",
                          "id": 50936074,
                          "name": "Ikemacs"
                      },
                      "background_color": "677479",
                      "id": 994922841,
                      "category": "seminars,recreation",
                      "box_header_background_color": "CECBAF",
                      "capacity": 100,
                      "num_attendee_rows": 0,
                      "title": "Body Shape Boot Camp",
                      "start_date": "2012-02-04 13:00:00",
                      "status": "Live",
                      "description": "<P><IMG SRC=\"https://evbdn.eventbrite.com/s3-s3/eventlogos/71025/bsbcflyercardcopy.jpg\" ALT=\"Body Shape Boot Camp Flyer\" WIDTH=\"600\" HEIGHT=\"408\"></P>",
                      "end_date": "2013-02-28 16:00:00",
                      "tags": "affordable boot camp fitness 4- weeks atlanta nutrition counseling training",
                      "text_color": "FFCC00",
                      "title_text_color": "",
                      "tickets": [
                          {
                              "ticket": {
                                  "description": "",
                                  "end_date": "2012-02-04 12:00:00",
                                  "min": 0,
                                  "max": 0,
                                  "price": "129.12",
                                  "visible": "true",
                                  "currency": "USD",
                                  "type": 0,
                                  "id": 12780709,
                                  "name": "Enlistee"
                              }
                          }
                      ],
                      "distance": "0.17M",
                      "created": "2012-01-25 09:52:08",
                      "url": "http://bodyshapebootcamp.eventbrite.com",
                      "box_text_color": "CECBAF",
                      "privacy": "Public",
                      "venue": {
                          "city": "Atlanta",
                          "name": "Old Fourth Ward Park",
                          "country": "United States",
                          "region": "GA",
                          "longitude": -84.364933,
                          "postal_code": "30308",
                          "address_2": "",
                          "address": "680 Dallas Street",
                          "latitude": 33.76919,
                          "country_code": "US",
                          "id": 1607095,
                          "Lat-Long": "33.76919 / -84.364933"
                      },
                      "modified": "2012-01-30 13:41:08",
                      "logo_ssl": "https://ebmedia.eventbrite.com/s3-s3/eventlogos/71025/994922841-1.jpg",
                      "repeats": "yes"
                  }
              }
          ]
      }
    END
=end
  end


end
