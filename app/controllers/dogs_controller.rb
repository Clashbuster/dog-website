class DogsController < ApplicationController
  before_action :set_dog, only: [:show, :edit, :update, :destroy]
  include HourlyLikesHelper

  # GET /dogs
  # GET /dogs.json
  def index
    if params[:page]
      @page = params[:page].to_i
    else
      @page = 0
    end

    range_start = @page * 5
    range_end = (@page * 5) + 5



    if params[:filter]
      liked_dogs = @likeshelper.past_hour
      puts liked_dogs
      @possible_dogs = []
      liked_dogs.each do |k, v|
        @possible_dogs << {"likes" => v, "dog" => k}
      end
      @possible_dogs.sort! { |a, b|  b['likes'] <=> a['likes'] }
      @possible_dogs.map! do |element|
        Dog.find_by(id: element['dog'])
      end
    else
      @possible_dogs = Dog.all[range_start..range_end - 1]
    end

    @next_valid = Dog.all[range_start..range_end].length === 6
    @dogs = Dog.all[range_start..range_end - 1]
    @first_partition = @dogs[0..1]
    @second_partition = @dogs[2..3]
  end

  # GET /dogs/1
  # GET /dogs/1.json
  def show
    dog = Dog.find_by(id: params[:id])
    if dog.user.present?
      @edit_valid = true if dog.user.id == current_user.id
    end
    
    if params[:likes]
      if dog.likes.present?
        dog.likes += 1
        dog.save!
      else
        dog.likes = 1
        dog.save!
      end
    end
  end

  # GET /dogs/new
  def new
    @dog = Dog.new
  end

  # GET /dogs/1/edit
  def edit
  end

  # POST /dogs
  # POST /dogs.json
  def create
    @dog = Dog.new(dog_params)
    @dog.user = current_user

    respond_to do |format|
      if @dog.save
        @dog.images.attach(params[:dog][:image]) if params[:dog][:image].present?

        format.html { redirect_to @dog, notice: 'Dog was successfully created.' }
        format.json { render :show, status: :created, location: @dog }
      else
        format.html { render :new }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dogs/1
  # PATCH/PUT /dogs/1.json
  def update
    respond_to do |format|
      if @dog.update(dog_params)
        @dog.images.attach(params[:dog][:image]) if params[:dog][:image].present?

        format.html { redirect_to @dog, notice: 'Dog was successfully updated.' }
        format.json { render :show, status: :ok, location: @dog }
      else
        format.html { render :edit }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dogs/1
  # DELETE /dogs/1.json
  def destroy
    @dog.destroy
    respond_to do |format|
      format.html { redirect_to dogs_url, notice: 'Dog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private


    def setup_likes_helper
      if !@likeshelper
        @likeshelper = HourlyLikes.new
      end
  
      if @likeshelper.begin
        @likeshelper.start
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_dog
      @dog = Dog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dog_params
      params.require(:dog).permit(:name, :likes, :description, :page, :filter,  :images => [])
    end
end
