# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).ready ->
  map = L.mapbox.map('map', 'allegrem.ifmbko0h').setView([30,0], 3)
  map.zoomControl.removeFrom(map)

  myLayer = L.mapbox.featureLayer().addTo(map)

  $.ajax
    dataType: 'json'
    url: '/users'
    success: (json) ->
      geojson = type: 'FeatureCollection', features: []
      for u in json.users
        geojson.features.push
          type: 'Feature'
          properties:
            title: u.name + ' @ ' + u.company
            'marker-size': 'large'
            'marker-symbol': 'heart'
            'marker-color': '#f39c12'
          geometry:
            type: 'Point'
            coordinates: u.coordinates
      myLayer.setGeoJSON(geojson)

  myLayer.on 'mouseover', (e) -> e.layer.openPopup()
  myLayer.on 'mouseout', (e) -> e.layer.closePopup()


  $form = $('#new_user')
  $openForm = $('#open-form')

  $openForm.click ->
    $form.fadeIn(300).find('input:not([type=hidden])').first().focus()
    $(this).fadeOut(300)

  $(document).keyup (e) ->
    if e.keyCode == 27
      $form.fadeOut(300)
      $openForm.fadeIn(300)
