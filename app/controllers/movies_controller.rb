class MoviesController < ApplicationController
  
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
    Movie.order(:title)
  end

  def index
    #Part1
    
    sortBy = params[:sortBy]
    ratings = params[:ratings]
    if(sortBy == nil && session[:sortBy]!=nil)
      sortBy = session[:sortBy]
      colName = session[:sortBy]
      #redirect_to movies_path(:sortBy => session[:sortBy],:ratings => ratings)
    end
    if(ratings == nil && session[:saved_params]!=nil)
      ratings = session[:saved_params]
      #redirect_to movies_path(:sortBy => session[:sortBy],:ratings => ratings)
    end
    
    #render :text => ratings.inspect
    if(sortBy == "title")
       @movies = Movie.all.order(:title)
       session[:sortBy] = "title"
     elsif(sortBy == "releaseDate")
      @movies = Movie.all.order(:release_date)
      session[:sortBy] = "releaseDate"
    else
    @movies = Movie.all
  end
  @all_ratings = Movie.select(:rating).map(&:rating).uniq
#render :text => ratings.inspect
  if(ratings == nil && session[:saved_params]==nil)
  ratings_map = Hash.new
  for r in @all_ratings
    ratings_map[r] = true
  end

else
  ratings_map = ratings
  #render :text => @all_ratings.inspect
end
@all_ratings = ratings_map
session[:saved_params] = ratings_map
#############################################################

  if(ratings!=nil)
   
    array = ratings.keys
     for key,value in @all_ratings
      if array.include?(key)
        ratings_map[key] = true
      else
        ratings_map[key] = false
      end
    end

    @all_ratings = ratings_map
    for i in 0..array.length
      if(i==0)
      @movies=(Movie.where(rating: array.at(i)))
      else
        @movies = @movies+(Movie.where(rating: array.at(i)))
    end
    end
  end
    @movies
  end

  def new
    # default: render 'new' template
  end

  def colName()
    sortBy = params[:sortBy]
    if(sortBy == 'title')
      'title'
      
    elsif(sortBy == 'releaseDate')
      'releaseDate'
    else
      nil
    end
  end

  def hilite
    sortBy = params[:sortBy]
    if(sortBy == 'title')
      @titleCol = 'title'
      'hilite'
      
    elsif(sortBy == 'releaseDate')
      @dateCol = 'releaseDate'
       'hilite'
    else
      ''
    end

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
  helper_method :hilite
  helper_method :colName
end
