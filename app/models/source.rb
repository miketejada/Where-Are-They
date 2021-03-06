class Source

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  def persisted?
    false
  end

  def get_twitter_feed(actor_name)

    client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['twitter_consumer_key']
    config.consumer_secret     = ENV['twitter_consumer_secret']
    config.access_token        = ENV['twitter_access_token']
    config.access_token_secret = ENV['twitter_access_secret']
    end

    possible_actors = client.user_search(actor_name)
    actor_screen_name = possible_actors.select {|a| a.verified? == true && a.name.strip.downcase == actor_name.downcase}.first
    
    if actor_screen_name
      client.user_timeline(actor_screen_name).take(5)
    else
      client.search(actor_name, lang: "en").take(10).select {|t| t.text.include?(actor_name)}
    end
  end

  def get_actor_data(actor_name)
    url = "http://api.themoviedb.org/3/search/person?api_key=#{ENV['movie_database_api_key']}&query=#{actor_name.gsub(' ', '%20')}"
    json = JSON.load(open(url))
    actor_id = json['results'].first['id']
    actor_credits_url = "http://api.themoviedb.org/3/person/#{actor_id}/combined_credits?api_key=#{ENV['movie_database_api_key']}"
    json = JSON.load(open(actor_credits_url))
    filmography_data = json['cast'].collect {|m| [m['release_date'] ? m['release_date'][0..3] : "", m['title'] ? m['title'] : "", m['id']]}
    all_movie_ids = filmography_data.collect {|m| m[2]}
    filmography_data = filmography_data.select {|m| m[0] != ""}
    filmography_data.collect {|m| "#{m[0]}: #{m[1]}"}.sort.reverse
  end

  # def get_giphy(actor_name)
  #   url = "http://api.giphy.com/v1/gifs/search?q=#{actor_name.gsub(' ', '%20')}&api_key=dc6zaTOxFJmzC" # public API key
  #   json = JSON.load(open(url))
  #   giphy_array = json['data'].collect {|g| g['embed_url']}
  #   giphy_array[0..9]
  # end

end