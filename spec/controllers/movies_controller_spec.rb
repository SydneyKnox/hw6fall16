require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      allow(Movie).to receive(:find_in_tmdb)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to redirect_to('movies/search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end 
    it 'should return an empty array with no matching movies' do
      fake_results = []
      post :search_tmdb, {:search_terms => 'asdfg'}
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      expect(response).to redirect_to('movies/search_tmdb')
      expect(flash[:notice]).to eq("No matching movies were found on TMDb.")
    end
    it 'if flash "No Movies Selected" if no movies checked' do 
      post :add_tmdb, {:tmdb_movies => []}
      expect(response).to redirect_to('/movies')
      expect(flash[:notice]).to eq("No movies selected")
    end
    it 'flash invalid input if empty input' do
      post :search_tmdb, {:search_terms => ''}
      expect(response).to redirect_to('/movies')
      expect(flash[:notice]).to eq("Invalid search term")
    end
  end
end
