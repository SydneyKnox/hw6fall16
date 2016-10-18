class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      @new_movies = Tmdb::Movie.find(string)
      returnedMovies = []
      if( @new_movies != nil)
        #flash[:warning] = "found movies"
        @new_movies.each do |movie|
          usa = Tmdb::Movie.releases(movie.id)
          countries = usa["countries"].find {|rating| rating['iso_3166_1'] == "US"}
          if(countries != nil)
            rating = countries["certification"]
            if rating != nil && rating != ''
              returnedMovies.push({"title" => movie.title, "tmdb_id" => movie.id, "overview" => movie.overview, "rating" => rating, "release_date" => movie.release_date})
            else
              returnedMovies.push({"title" => movie.title, "tmdb_id" => movie.id, "overview" => movie.overview, "rating" => "NR", "release_date" => movie.release_date})
            end
          end
        end
        return returnedMovies
     end
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.create_from_tmdb(id)
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      movie = Tmdb::Movie.detail(id)
      usa = Tmdb::Movie.releases(id)["countries"].find {|rating| rating['iso_3166_1'] == "US"}
        if(usa != nil)
          rating = usa["certification"]
        else
          rating = "NR"
        end #title rating description release_date
      #puts id
      #puts movie.title
      #puts movie.overview
      Movie.create({:title => movie['title'], :rating => rating, :description => movie['overview'], :release_date => movie['release_date']})
      #flash[:warning] = "movies created"
  end

end