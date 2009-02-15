module ContestsHelper
 def  medal_color(num)
   if num > 3
     return ''
   end
   if num == 1
     image_tag('cup-gold.png', :title=> 'Алт')
   elsif num == 2
     image_tag('cup-silver.png', :title=> 'Мөнгө')
   elsif num == 3
     image_tag('cup-bronze.png', :title=> 'Хүрэл')
   end
 end
 def show_place(num)
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
end
