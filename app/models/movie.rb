class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Movie.find(string)
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.create_from_tmdb(id)
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      movie = Tmdb::Movie.detail(id)
      usa = Tmdb::Movie.releases(movie.id)["countries"].find {|rating| rating['iso_3166_1'] == "US"}
        if(usa != nil)
          rating = usa["certification"]
        else
          rating = "NR"
        end #title rating description release_date
      puts id
      puts movie.title
      puts movie.overview
      Movie.create!({:movie => id, :title => movie.title, :rating => rating, :description => movie.overview, :release_date => movie.release_date})
      flash[:warning] = "movies created"
  end

end