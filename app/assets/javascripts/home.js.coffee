# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).ready ->
#  map.zoomControl.removeFrom(map)

  $form = $('form')
  $openForm = $('#open-form')

  $openForm.click ->
    $form.fadeIn(300).find('input').first().focus()
    $(this).fadeOut(300)

  $(document).keyup (e) ->
    if e.keyCode == 27
      $form.fadeOut(300)
      $openForm.fadeIn(300)
