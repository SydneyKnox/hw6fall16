class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering,@title_header = {:title => :asc}, 'hilite'
    when 'release_date'
      ordering,@date_header = {:release_date => :asc}, 'hilite'
    end
    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings] || session[:ratings] || {}
    
    if @selected_ratings == {}
      @selected_ratings = Hash[@all_ratings.map {|rating| [rating, rating]}]
    end
    
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    @movies = Movie.where(rating: @selected_ratings.keys).order(ordering)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def search_tmdb
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    @searchTerm = params[:search_terms]
    @returnedMovies = []
    if :search_terms == '' || :search_terms == nil
      flash[:warning] = "Invalid Search Term"
      redirect_to movies_path
    else
      @new_movies=Movie.find_in_tmdb(params[:search_terms])
      flash[:warning] = "found movies"
      @new_movies.each do |movie|
        usa = Tmdb::Movie.releases(movie.id)["countries"].find {|rating| rating['iso_3166_1'] == "US"}
        if(usa != nil)
          rating = usa["certification"]
          if rating != nil && rating != ''
            @returnedMovies.push({"title" => movie.title, "tmdb_id" => movie.id, "overview" => movie.overview, "rating" => rating, "release_date" => movie.release_date})
          else
            @returnedMovies.push({"title" => movie.title, "tmdb_id" => movie.id, "overview" => movie.overview, "rating" => "NR", "release_date" => movie.release_date})
          end
        end
      end
      
    end
    if @new_movies == nil
      flash[:warning] = "'#{params[:search_terms]}' was not found in TMDb."
      redirect_to movies_path
    end
  end
  
  def add_tmdb
    movies_to_add = params[:tmdb_movies]
    arr = movies_to_add.keys
    arr.each do |movie|
      Movie.create_from_tmdb(movie)
    end
  end

end

