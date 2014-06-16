# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


class Map
  constructor: ->
    @map = L.mapbox.map('map', 'allegrem.ifmbko0h', {minZoom: 2, worldCopyJump: true}).setView([18,13], 2)
    @map.zoomControl.removeFrom(@map)

    @myLayer = L.mapbox.featureLayer().addTo(@map)
    @myLayer.on 'mouseover', (e) -> e.layer.openPopup()
    @myLayer.on 'mouseout', (e) -> e.layer.closePopup()
    @myLayer.on 'click', (e) => @map.panTo e.layer.getLatLng()

    @geojson = type: 'FeatureCollection', features: []

  _generateGeoJSON: (user) ->
    sameMarker = @geojson.features.find (u) ->
      u.geometry.coordinates[0] is user.coordinates[0] and u.geometry.coordinates[1] is user.coordinates[1]
    if sameMarker
      if sameMarker.properties.className.indexOf('multi') is -1
        sameMarker.properties.label = 1
        sameMarker.properties.className += ' multi'
      sameMarker.properties.label += 1
      sameMarker.properties.title += '<br />' + user.name + ' @ ' + user.company
      return sameMarker
    else
      {
        type: 'Feature'
        properties:
          title: user.name + ' @ ' + user.company
          name: user.name
          label: user.label
          className: 'myMarker'
        geometry:
          type: 'Point'
          coordinates: user.coordinates
      }

  add: (user, opts={}) ->
    f = @_generateGeoJSON user
    f.properties.className += ' animate'  if opts.animate
    @geojson.features.push f  if f.properties.className.indexOf('multi') is -1
    if opts.refresh
      @refresh()
      @focusOn user.name

  refresh: ->
    @myLayer.setGeoJSON(@geojson).eachLayer (marker) ->
      marker.setIcon L.divIcon
        className: marker.feature.properties.className
        html: marker.feature.properties.label
        iconSize: [40, 40]

  focusOn: (name) ->
    marker = @_findMarker name
    if marker
      marker.openPopup()
      @map.setView marker.getLatLng(), 13

  _findMarker: (name) ->
    foundMarker = null
    @myLayer.eachLayer (marker) ->
      if marker.feature.properties.title.toLowerCase().indexOf(name.toLowerCase() + ' @') isnt -1
        foundMarker = marker
    return foundMarker

  updateOrAdd: (user, opts={}) ->
    prevUser = @geojson.features.findIndex (u) -> u.properties.name is user.name
    @geojson.features.splice prevUser, 1  if prevUser isnt -1
    @add user, opts

  openRandomPopup: ->
    @lastPopup.closePopup()  if @lastPopup
    if @map.getZoom() < 4
      index = Math.floor(Math.random()*@myLayer.getLayers().length)
      @lastPopup = @myLayer.getLayers()[index]
      @lastPopup.openPopup()
    setTimeout (=> @openRandomPopup()), 7000


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
          ga 'send', 'event', 'searchForm', 'userEntryClick', $(this).data('name')

      document.myMap.refresh()
      document.myMap.openRandomPopup()