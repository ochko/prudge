# -*- coding: utf-8 -*-
module ContestsHelper
 def standing(num)
   if num > 3
     return num
   end
   if num == 1
     image_tag('cup-gold.png', :title=> 'Алт')
   elsif num == 2
     image_tag('cup-silver.png', :title=> 'Мөнгө')
   elsif num == 3
     image_tag('cup-bronze.png', :title=> 'Хүрэл')
   end
 end

 def show_status(contest)
   if Time.now() < contest.start
     "Эхлэхэд #{distance_of_time_in_words_to_now contest.start} үлдлээ"
   elsif Time.now() > contest.start &&
       Time.now() < contest.end
     "Дуусахад #{distance_of_time_in_words_to_now contest.end} үлдлээ"
   else
     "Дууссан"
   end
 end

end
