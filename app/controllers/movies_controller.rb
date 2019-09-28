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
    #Part1
    #render :text => session[:saved_params].inspect
    #session.delete(:saved_params)

    flag = 0
     
    @all_ratings = Movie.select(:rating).map(&:rating).uniq
   

     if(ratings==nil && session[:saved_params]==nil)
      temp = Hash.new
      #render :text => session[:saved_params].inspect
      for i in 1..@all_ratings.length
          temp[@all_ratings[i-1]] = true
      end
      @all_ratings = temp
      session[:saved_params] = temp
    end


    if(ratings!=nil)
      
      temp = Hash.new
      #render :text => session[:saved_params].inspect
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

    if(ratings==nil && session[:saved_params] !=nil)
      #render :text => session[:saved_params].inspect
      @all_ratings  = session[:saved_params]
      flag = 1
    end

    if(session[:saved_params] ==nil)
      temp = Hash.new
      #render :text => session[:saved_params].inspect
      for i in 1..@all_ratings.length
          temp[@all_ratings[i-1]] = true
      end
      @all_ratings = temp
    end

    array = @all_ratings.map {|k,v| k if v==true} - [nil]
    for i in 0..array.length
          if(i==0)
          @movies=(Movie.where(rating: array.at(i)))
          else
            @movies = @movies+(Movie.where(rating: array.at(i)))
        end
    end

    if(sortBy == "title")
       session[:sortBy] = "title"
     elsif(sortBy == "release_date")
      session[:sortBy] = "release_date"
  end

   if(sortBy == nil && session[:sortBy]!=nil)
      sortBy = session[:sortBy]
      colName = session[:sortBy]
      flag = 1
      #redirect_to movies_path(:sortBy => session[:sortBy],:ratings => @all_ratings)
    end
#render :text => Movie.where(rating: array.at(1)).inspect
#render :text => Movie.where("rating in (?)", @all_ratings.keys).order(sortBy).inspect
 @movies = Movie.where("rating in (?)", array).order(sortBy)
 @movies
  end

  def new
    # default: render 'new' template
  end

  def colName()
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
