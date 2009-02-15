module ProblemsHelper
  def order_reverse(order)
    if order =~ /_desc/
      order.sub(/_desc/, '_asc')
    elsif order =~ /_asc/
      order.sub(/_asc/, '_desc')
    else
      order
    end
  end
end
