# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


#new user form
$(document).ready ->
  $form = $('#new_user')
  $openForm = $('#open-form')
  $submitButton = $form.find('input[type=submit]')
  $userCoordinates = $('#user_coordinates')

  closeForm = ->
    $form.fadeOut(300)
    $openForm.fadeIn(300)

  showErrors = (errors) ->
    err_html = '<ul>'
    err_html += "<li>#{e}</li>" for e in errors
    err_html += '</ul>'
    $form.find('.errors').html err_html

  $openForm.click ->
    $form.fadeIn(300).find('input:not([type=hidden])').first().focus()
    $(this).fadeOut(300)
    ga 'send', 'event', 'newUserForm', 'open'

  $form.keyup (e) ->
    closeForm()  if e.keyCode == 27

  $form.on 'submit', (e) ->
    if $userCoordinates.val() is ''
      $submitButton.addClass('disabled').val('Envoi...')
      address = "#{$('#user_city').val()} #{$('#user_country').val()}"
      $.ajax url: "http://maps.googleapis.com/maps/api/geocode/json?address=#{address}"
        .success (res) ->
          if res.results.length is 0
            showErrors ['The address is invalid.']
            $submitButton.removeClass('disabled').val('Envoyer')
          else
            location = res.results[0].geometry.location
            $userCoordinates.val "#{location.lng},#{location.lat}"
            $form.submit()
      return false
    else
      ga 'send', 'event', 'newUserForm', 'submit'

  $form.on 'ajax:success', (data, status, xhr) ->
    closeForm()
    $openForm.hide()
    document.myMap.updateOrAdd status.user, refresh: true, animate: true
    ga 'send', 'event', 'newUserForm', 'success'

  $form.on 'ajax:error', (xhr, status) ->
    $submitButton.removeClass('disabled').val('Envoyer')
    showErrors status.responseJSON.users
    $userCoordinates.val ''
    $form.find('input:not([type=hidden])').first().focus()
    ga 'send', 'event', 'newUserForm', 'error'


#search form
$(document).ready ->
  $form = $('#searchForm').focus()
  $userList = $('#userList')
  $moreResults = $userList.find('.moreResults').hide()

  MAX_USER_ITEMS = 5

  $form.keyup (e) ->
    switch e.keyCode
      when 13
        $('#userList .userEntry.visible').first().click()
      when 27
        $form.val ''
        $('#userList .userEntry').hide()
      else
        if $form.val() is ""
          $('#userList .userEntry').hide()
        else
          count = 0
          $('#userList .userEntry').each ->
            if removeDiacritics($(this).data('name').toLowerCase()).indexOf(removeDiacritics($form.val().toLowerCase())) isnt -1
              if count < MAX_USER_ITEMS
                $(this).slideDown().addClass 'visible'
              else
                $(this).slideUp().removeClass 'visible'
              count++
            else
              $(this).slideUp().removeClass 'visible'
          if count > MAX_USER_ITEMS then $moreResults.show().find('output').text(count-MAX_USER_ITEMS) else $moreResults.hide()
