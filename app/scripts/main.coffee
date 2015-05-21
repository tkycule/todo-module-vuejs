Vue = require("vue")
Vue.use(require("vue-validator"))

window.$ = window.jQuery = require("jquery")
window.page = require("page")
window.App = {}

App.env = process.env.env

app = new Vue(require("./components/app"))
session = require("./services/session.service")

$(document).on('click', 'a[href]', (e) ->
  e.preventDefault()
  page($(this).attr('href'))
)

$.ajaxSetup({
  dataType: 'json'
  beforeSend: (xhr) ->
    if currentUser = session.currentUser()
      xhr.setRequestHeader('Authorization', currentUser.authentication_token)
})

