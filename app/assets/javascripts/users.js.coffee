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

  $(document).keyup (e) ->
    closeForm()  if e.keyCode == 27

  $form.submit ->
    $submitButton.addClass('disabled').val('Envoi...')

  $form.on 'ajax:success', ->
    closeForm()
    $openForm.hide()

  $form.on 'ajax:error', (xhr, status) ->
    $submitButton.removeClass('disabled').val('Envoyer')
    err_html = '<ul>'
    err_html += "<li>#{e}</li>" for e in status.responseJSON.users
    err_html += '</ul>'
    $form.find('.errors').html err_html
    $form.find('input:not([type=hidden])').first().focus()


#search form
$(document).ready ->
  $form = $('#searchForm')
  $form.focus()
  $userList = $('#userList')

  $form.keyup ->
    if $form.val() is ""
      $('#userList .userEntry').hide()
    else
      $('#userList .userEntry').each ->
        if $(this).data('name').toLowerCase().indexOf($form.val().toLowerCase()) isnt -1
          $(this).slideDown()
        else
          $(this).slideUp()