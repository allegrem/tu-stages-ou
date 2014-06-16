# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

STACK_LIMIT = [0,0,35,12,6,1,0.17,0.08,0.02,0.004,0.0012,0.00013,0.00003,0.000021,0.000005,0.000000000001,0.000000000001,0.000000000001,0.000000000001,0.000000000001,0.000000000001,0.000000000001,0]

class Map
  constructor: ->
    @map = L.mapbox.map('map', 'allegrem.ifmbko0h', {minZoom: 2, worldCopyJump: true}).setView([18,13], 2)
    @map.zoomControl.removeFrom(@map)

    @myLayer = L.mapbox.featureLayer().addTo(@map)
    @myLayer.on 'mouseover', (e) -> e.layer.openPopup()
    @myLayer.on 'mouseout', (e) -> e.layer.closePopup()
    @myLayer.on 'click', (e) => @map.panTo e.layer.getLatLng()

    @map.on 'zoomend', @refresh, @

    @users = []

  _generateGeoJSON: ->
    geojson = type: 'FeatureCollection', features: []
    for user in @users
      marker = geojson.features.find (u) =>
        (u.geometry.coordinates[0] - user.coordinates[0])**2 + (u.geometry.coordinates[1] - user.coordinates[1])**2 < STACK_LIMIT[@map.getZoom()]
      if marker
        if marker.properties.className.indexOf('multi') is -1
          marker.properties.label = 1
          marker.properties.className += ' multi'
        marker.properties.label += 1
        marker.properties.className += (user.className || '')
        marker.properties.name += ',' + user.name
        if marker.properties.label == 7
          marker.properties.title += '<br />and more...'
        else if marker.properties.label < 7
          marker.properties.title += '<br />' + user.name + ' @ ' + user.company
      else
        marker = {
          type: 'Feature'
          properties:
            title: user.name + ' @ ' + user.company
            name: user.name
            label: user.label
            className: 'myMarker' + (user.className || '')
          geometry:
            type: 'Point'
            coordinates: user.coordinates
        }
        geojson.features.push marker
      user.marker = marker
    geojson

  add: (user, opts={}) ->
    user.className = ' animate'  if opts.animate
    @users.push user
    if opts.refresh
      @refresh()
      @focusOn user.name

  refresh: ->
    @myLayer.setGeoJSON(@_generateGeoJSON()).eachLayer (marker) ->
      marker.setIcon L.divIcon
        className: marker.feature.properties.className
        html: marker.feature.properties.label
        iconSize: [40, 40]

  focusOn: (name) ->
    user = @users.find (u) -> u.name.indexOf(name) isnt -1
    if user
      @map.setView [user.coordinates[1],user.coordinates[0]], 13
      @_findMarker(name).openPopup()

  _findMarker: (name) ->
    foundMarker = null
    @myLayer.eachLayer (marker) ->
      if marker.feature.properties.name.toLowerCase().indexOf(name.toLowerCase()) isnt -1
        foundMarker = marker
    return foundMarker

  updateOrAdd: (user, opts={}) ->
    prevUser = @users.findIndex (u) -> u.name is user.name
    @users.splice prevUser, 1  if prevUser isnt -1
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