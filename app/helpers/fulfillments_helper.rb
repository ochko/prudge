module FulfillmentsHelper
  def payment_status(f)
    if f.payd
      link_to_remote(image_tag('payment-done.png'),
              :url=>{ :controller=>'fulfillments',
                       :action=>'pay', :id=>f.id},
                     :method=>'post',
                     :confirm=>'Төлбөр хийгдээгүй юу?')
    else
      link_to_remote(image_tag('payment-waiting.png'),
              :url=>{ :controller=>'fulfillments',
                       :action=>'pay', :id=>f.id},
                     :method=>'post',
                     :confirm=>'Төлбөр хийгдсэн үү?')
    end
  end

  def payment_status_show(payd)
    if payd
      image_tag('payment-done.png') + ' Төлөгдсөн'
    else
      image_tag('payment-waiting.png') + ' Төлөөгүй'
    end
  end
end
