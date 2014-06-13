# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


class Map
  constructor: ->
    @map = L.mapbox.map('map', 'allegrem.ifmbko0h', {minZoom: 3, worldCopyJump: true}).setView([18,13], 3)
    @map.zoomControl.removeFrom(@map)

    @myLayer = L.mapbox.featureLayer().addTo(@map)
    @myLayer.on 'mouseover', (e) -> e.layer.openPopup()
    @myLayer.on 'mouseout', (e) -> e.layer.closePopup()
    @myLayer.on 'click', (e) => @map.panTo e.layer.getLatLng()

    @geojson = type: 'FeatureCollection', features: []

  _generateGeoJSON: (user) ->
    sameMarker = @geojson.features.filter (u) ->
      u.geometry.coordinates[0] is user.coordinates[0] and u.geometry.coordinates[1] is user.coordinates[1]
    if sameMarker.length is 0
      {
        type: 'Feature'
        properties:
          title: user.name + ' @ ' + user.company
          label: user.label
          className: 'myMarker'
        geometry:
          type: 'Point'
          coordinates: user.coordinates
      }
    else
      sameMarker = sameMarker[0]
      if sameMarker.properties.className.indexOf 'multi' is -1
        sameMarker.properties.label = 1
        sameMarker.properties.className += ' multi'
      sameMarker.properties.label += 1
      sameMarker.properties.title += '<br />' + user.name + ' @ ' + user.company
      sameMarker

  add: (user, opts={}) ->
    f = @_generateGeoJSON user
    f.properties.className += ' animate'  if opts.animate
    @geojson.features.push f  if f.properties.className.indexOf('multi') is -1
    @refresh()  if opts.refresh

  refresh: ->
    @myLayer.setGeoJSON(@geojson).eachLayer (marker) ->
      marker.setIcon L.divIcon
        className: marker.feature.properties.className
        html: marker.feature.properties.label
        iconSize: [40, 40]

  focusOn: (name) ->
    @myLayer.eachLayer (marker) =>
      if marker.feature.properties.title.toLowerCase().indexOf((name+' @').toLowerCase()) isnt -1
        marker.openPopup()
        @map.setView marker.getLatLng(), 13



$(document).ready ->
  document.myMap = new Map()
  $userList = $('#userList')

  $.ajax
    dataType: 'json'
    url: '/users'
    success: (json) ->
      for u in json.users
        document.myMap.add u

        userEntry = $("<div class=\"userEntry\" data-name=\"#{u.name}\"><strong>#{u.name}</strong>#{u.company} (#{u.city} - #{u.country})</div>")
        $userList.prepend userEntry.hide()
        userEntry.click ->
          document.myMap.focusOn $(this).data('name')
          $('#userList .userEntry').hide()
          $('#searchForm').val $(this).data('name')
          ga 'send', 'event', 'searchForm', 'userEntryClick'

      document.myMap.refresh()