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

requireLogin = (ctx, next) ->
  if session.currentUser()
    next()
  else
    page.redirect("/")

skipLogin = (ctx, next) ->
  if session.currentUser()
    page.redirect("/tasks")
  else
    next()

page("/", skipLogin, ->
  app.view = "index"
)

page("/logout", requireLogin, ->
  session.logout()
  app.$broadcast("changeCurrentUser")
  app.$emit('Layout:flash', {class: 'alert-info', message: 'ログアウトしました。'})
  page.redirect("/")
)

page("/users/new", skipLogin, ->
  app.view = "new_user"
)

page("/tasks", requireLogin, ->
  app.view = "tasks"
  App.state = "inbox"
  app.$broadcast("changeState")
)

page("/tasks/:state", requireLogin, (ctx) ->
  app.view = "tasks"
  App.state = ctx.params.state
  app.$broadcast("changeState")
)

page("/tasks/:id/edit", requireLogin, (ctx) ->
  app.id = ctx.params.id
  app.view = "task_edit"
)

page("*", ->
  page.redirect("/")
)

page()
