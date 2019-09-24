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
    sortBy = params[:sortBy]
    #render :text => id.inspect
    if(sortBy == "title")
       @movies = Movie.all.order(:title)
     elsif(sortBy == "releaseDate")
      @movies = Movie.all.order(:release_date)
    else
    @movies = Movie.all
  end
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

  def hilite()
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
