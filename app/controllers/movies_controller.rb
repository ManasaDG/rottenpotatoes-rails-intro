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
    require 'logger'
    log = Logger.new('log.txt')
    sortBy = params[:sortBy]
    ratings = params[:ratings]

    flag = 0
    
    #Retrieve all ratings from DB
    @all_ratings = Movie.select(:rating).map(&:rating).uniq

    #Condition for redirect for ratings
    if(ratings==nil && session[:saved_params]!=nil)
      flag = 1
    end

    #Condition for redirect for order
    if(sortBy==nil && session[:sortBy]!=nil)
      flag=1
    end


     #No session params for ratings, check all ratings
     if(ratings==nil && session[:saved_params]==nil)
      temp = Hash.new
      for i in 1..@all_ratings.length
          temp[@all_ratings[i-1]] = true
      end
      @all_ratings = temp
      session[:saved_params] = temp
    end

    #Ratings passed through url params, update session params
    if(ratings!=nil)
      
      temp = Hash.new
      
      for i in 0..@all_ratings.length-1
        if ratings.key?(@all_ratings[i]) == true
          temp[@all_ratings[i]] = true
        else
          temp[@all_ratings[i]] = false
        end
      end
      ratings = temp
      session[:saved_params] = ratings
      @all_ratings  = ratings
    end

    #No url params, update ratings to session params
    if(ratings==nil && session[:saved_params] !=nil)
      @all_ratings  = session[:saved_params]
    end

    if(session[:saved_params] ==nil)
      temp = Hash.new
      for i in 1..@all_ratings.length
          temp[@all_ratings[i-1]] = true
      end
      @all_ratings = temp
    end

    #Get ratings which need to be checked (value==true)
    #Filter movies based on ratings selected
    array = @all_ratings.map {|k,v| k if v==true} - [nil]
    for i in 0..array.length
          if(i==0)
          @movies=(Movie.where(rating: array.at(i)))
          else
            @movies = @movies+(Movie.where(rating: array.at(i)))
        end
    end

    #Setting Ordering parameters
    if(sortBy == "title")
       session[:sortBy] = "title"
     elsif(sortBy == "release_date")
      session[:sortBy] = "release_date"
  end

   if(sortBy == nil && session[:sortBy]!=nil)
      sortBy = session[:sortBy]
      colName = session[:sortBy]
    end

    #Redirect if needed
    if(flag==1)
      @all_ratings.reject! {|k,v| v == false}
      session[:saved_params] = @all_ratings
      flash.keep
      redirect_to movies_path({:sortBy => sortBy,:ratings => @all_ratings})
    end

    #Apply Ordering and Filtering to movies and return
 @movies = Movie.where("rating in (?)", array).order(sortBy)

 @movies
  end

  def new
    # default: render 'new' template
  end

  def colName()
    #Toggle class for column based sorting
    sortBy = params[:sortBy]
    if(sortBy == 'title')
      'title'
      
    elsif(sortBy == 'release_date')
      'release_date'
    else
      nil
    end
  end

  def hilite
    #Apply class to column based sorting
    sortBy = params[:sortBy]
    if(sortBy == 'title')
      @titleCol = 'title'
      'hilite'
      
    elsif(sortBy == 'release_date')
      @dateCol = 'release_date'
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
