user = null

module.exports =

  currentUser: ->
    if localStorage.user
      user ||= JSON.parse(localStorage.user)
    else
      return null

  logout: ->
    localStorage.removeItem('user')
    user = null

  setUser: (_user) ->
    localStorage.user = JSON.stringify(_user)
    user = _user
