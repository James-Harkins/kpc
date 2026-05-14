class CoursesController < ApplicationController
  before_action :require_site_admin

  def index
    @courses = Course.all.order(:name)
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to courses_path
    else
      flash[:error] = @course.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])
    if @course.update(course_params)
      redirect_to courses_path
    else
      flash[:error] = @course.errors.full_messages.to_sentence
      render :edit
    end
  end

  private

  def course_params
    params.require(:course).permit(:name, :address)
  end
end
