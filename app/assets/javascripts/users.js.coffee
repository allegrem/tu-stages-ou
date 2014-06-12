# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


#new user form
$(document).ready ->
  $form = $('#new_user')
  $openForm = $('#open-form')
  $submitButton = $form.find('input[type=submit]')

  closeForm = ->
    $form.fadeOut(300)
    $openForm.fadeIn(300)

  $openForm.click ->
    $form.fadeIn(300).find('input:not([type=hidden])').first().focus()
    $(this).fadeOut(300)

  $form.keyup (e) ->
    closeForm()  if e.keyCode == 27

  $form.submit ->
    $submitButton.addClass('disabled').val('Envoi...')

  $form.on 'ajax:success', (data, status, xhr) ->
    closeForm()
    $openForm.hide()
    document.myMap.add status.user, refresh: true

  $form.on 'ajax:error', (xhr, status) ->
    $submitButton.removeClass('disabled').val('Envoyer')
    err_html = '<ul>'
    err_html += "<li>#{e}</li>" for e in status.responseJSON.users
    err_html += '</ul>'
    $form.find('.errors').html err_html
    $form.find('input:not([type=hidden])').first().focus()


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
            if $(this).data('name').toLowerCase().indexOf($form.val().toLowerCase()) isnt -1
              if count < MAX_USER_ITEMS
                $(this).slideDown().addClass 'visible'
              else
                $(this).slideUp()
              count++
            else
              $(this).slideUp()
          if count > MAX_USER_ITEMS then $moreResults.show().find('output').text(count-MAX_USER_ITEMS) else $moreResults.hide()
