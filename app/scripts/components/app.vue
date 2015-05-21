<template>
  <header v-component="header"></header>

  <div class="container-fluid">

    <div v-if="flash" class="alert alert-dismissible fade in" v-class="flash.class">
      <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
      <p>{{flash.message}}</p>
    </div>

    <div id="main" v-component="{{view}}"></div>
  </div>
</template>

<script lang="coffee" type="text/coffeescript">

module.exports = {

  el: "#app"

  data: ->
    view: ""
    flash: null

  components:
    header: require("./header")

  created: ->

    @$on("changeCurrentUser", =>
      @$broadcast("changeCurrentUser")
    )

    @$on("Layout:flash", (message) =>
      @flash = message
    )
}

</script>

