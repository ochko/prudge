module AccountHelper
  def show_photo(user)
    photo = user.photo
    if !photo.nil?
      if current_user.id == user.id
        return link_to(image_tag(photo.public_filename(:thumb)),
                       :controller => 'photos',
                       :action => 'new',
                       :id => photo, :user_id => user)
      else
        return image_tag(photo.public_filename(:thumb))
      end
    end
    if current_user.id == user.id
      return link_to(image_tag("/images/no-photo.png"),
                     :controller => 'photos',
                     :action => 'new',
                     :user_id => user)
    else
      return image_tag("/images/no-photo.png")
    end
  end
end
