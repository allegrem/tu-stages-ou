# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).ready ->
  map = L.map('map').setView([30, 0], 3)

  L.tileLayer('http://{s}.tiles.mapbox.com/v3/allegrem.ifmbko0h/{z}/{x}/{y}.png', {
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
      maxZoom: 18
  }).addTo(map)

  map.zoomControl.removeFrom(map)

  $form = $('form')
  $openForm = $('#open-form')

  $openForm.click ->
    $form.fadeIn(500).find('input').first().focus()
    $(this).fadeOut(500)

  $(document).keyup (e) ->
    if e.keyCode == 27
      $form.fadeOut(500)
      $openForm.fadeIn(500)
