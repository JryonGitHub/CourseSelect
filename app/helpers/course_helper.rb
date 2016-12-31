module CourseHelper
    
    #-------------------------sum the score that have been selected----------------------
    def sum_score()
        sum = 0
        @course.each do |course|
            temp = course.credit.split("/")
            sum += temp[1].to_i
        end
        sum
    end
end
