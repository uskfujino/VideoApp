#$(
#  () ->
    try
      pickerCallback = (data) ->
        if data.action == google.picker.Action.PICKED
          field = data.docs[0].id
          alert('The user selected: ' + fileId)

      createPicker = () ->
        view = new google.picker.View(google.picker.ViewId.DOCS)
        view.setMimeTypes 'image/png,image/jpeg,image/jpg,text/mind,text/csv'
        picker = new google.picker.PickerBuilder()
          .enableFeature(google.picker.Feature.NAV_HIDDEN)
          .enableFeature(google.picker.Feature.MULTISELECT_ENABLED)
          .setAppId('254075258111.apps.googleusercontent.com')
          .addView(view)
          .setCallback(pickerCallback)
          .build()
        picker.setVisible true

      showGooglePicker = () ->
        google.setOnLoadCallback createPicker
        google.load 'picker', '1'
    catch ex
      alert ex
#)
