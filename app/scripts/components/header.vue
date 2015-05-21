<template>
  <header>
    <nav class="navbar navbar-default" role="navigation">
      <div class="container-fluid">
        <div class="navbar-header">
          <a class="navbar-brand" href="/">TODO-Module Vue</a>
        </div>
        <div class="collapse navbar-collapse">
          <ul v-if="!currentUser" class="nav navbar-nav navbar-right">
            <li><a href="/">ログイン</a></li>
            <li><a href="/users/new">新規登録</a></li>
          </ul>
          <ul v-if="currentUser" class="is-login nav navbar-nav navbar-right">
						<li><p v-text="currentUser.email" class="email navbar-text"></p></li>
            <li><a id="logout" href="/logout">ログアウト</a></li>
          </ul>
        </div>
      </div>
    </nav>
  </header>
</template>

<script lang="coffee" type="text/coffeescript">

session = require("../services/session.service")

module.exports =

  replace: true

  data: ->
    currentUser: session.currentUser()

  created: ->
    @$on("changeCurrentUser", =>
      @currentUser = session.currentUser()
    )

</script>
