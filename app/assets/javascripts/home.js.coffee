# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).ready ->
  map = L.mapbox.map('map', 'allegrem.ifmbko0h').setView([30,0], 3)
  map.zoomControl.removeFrom(map)

  myLayer = L.mapbox.featureLayer().addTo(map)

  $userList = $('#userList')

  $.ajax
    dataType: 'json'
    url: '/users'
    success: (json) ->
      geojson = type: 'FeatureCollection', features: []
      for u in json.users
        userEntry = $("<div class=\"userEntry\" data-name=\"#{u.name}\"><strong>#{u.name}</strong>#{u.company} (#{u.city} - #{u.country})</div>")
        $userList.prepend userEntry.hide()

        geojson.features.push
          type: 'Feature'
          properties:
            title: u.name + ' @ ' + u.company
            label: u.label
          geometry:
            type: 'Point'
            coordinates: u.coordinates
      myLayer.setGeoJSON(geojson).eachLayer (marker) ->
        marker.setIcon L.divIcon({ className: 'myMarker', html: marker.feature.properties.label, iconSize: [40,40] })

  myLayer.on 'mouseover', (e) -> e.layer.openPopup()
  myLayer.on 'mouseout', (e) -> e.layer.closePopup()