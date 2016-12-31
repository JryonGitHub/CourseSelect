class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

    #-------QiaoCode--------
  public
  
  def open
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(:open=>true)
      flash={:info => "开通成功"}
    else
      flash={:warning => "开通失败"}
    end
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
   @course = Course.find_by_id(params[:id])
    if @course.update_attributes(:open=>false)
      flash={:info => "关闭成功"}
    else
      flash={:warning => "关闭失败"}
    end
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  #-------------------------for students----------------------

  def list
    #-------QiaoCode--------
    @course=Course.where(:open=>true)
    @course=@course-current_user.courses
  end

  def select
    @course=Course.find_by_id(params[:id])
    result = is_conflict?(@course)
    if result[:flag]
      flash={:suceess => "您选择的#{@course.name}与#{result[:course].name}时间冲突!"}
      redirect_to courses_path, flash: flash
    else
      current_user.courses<<@course
      if @course.limit_num == nil ||@course.student_num < @course.limit_num      
        @course.student_num = @course.student_num + 1
      else 
        @course.student_num = @course.limit_num
      end
      @course.save
      flash={:suceess => "成功选择课程: #{@course.name}"}
      redirect_to courses_path, flash: flash
    end
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    if @course.student_num > 0
      @course.student_num = @course.student_num - 1
    else
      @course.student_num = 0
    end
    @course.save
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
  end


  private
  
  #-------------------------to avoid the conflict  time----------------------
  def is_conflict?(course)
    conflict_flag = false
    value = ''
    current_user.courses.each do |item|
      if course.course_time.eql?(item.course_time)
        conflict_flag = true
        value = item
        break
      end
    end
      {:flag => conflict_flag, :course => value}    
  end

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end


end
