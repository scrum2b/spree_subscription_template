# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

checkout_function = () ->
  $.ajax
    url: '/order/checkout'
    beforeSend : (xhr) -> 
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    type: 'POST'
    data: "product=" + $(this).attr("product") + '&quantity=' + $(this).parent().find("input").val() 
    dataType: "json"
    success: (response) ->
      window.location.href = "/order/address"
 $(document).on('click', '#checkout', checkout_function)

shiping_function = () ->
  $.ajax
    url: '/order/shiping'
    beforeSend : (xhr) -> 
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    type: 'PATCH'
    data: $('#form-ship').serialize()
    dataType: "json"
    success: (response) ->
      window.location = "/order/payment"
 $(document).on('click', '#ship', shiping_function)

end_payment_function = () ->
  $.ajax
    url: '/order/complete'
    beforeSend : (xhr) -> 
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    type: 'POST'
    data: $('#form-billing').serialize()
    dataType: "json"
    success: (response) ->
      window.location = "/"
 $(document).on('click', '#end_payment', end_payment_function)
