<template>

<h1>ログイン</h1>

<div class="well">
  <form v-on="submit: onSubmit($event)" novalidate="novalidate" class="simple_form new_user" id="new_user" accept-charset="UTF-8" method="post">

    <div v-class="has-error: validation.email.dirty && validation.email.invalid" class="form-group email required user_email">
      <label class="control-label" for="user_email">
        <abbr title="required">*</abbr>
        メールアドレス
      </label>
      <input v-model="email" v-validate="required, email" class="form-control" type="email" name="email" id="user_email" />
      <span v-if="validation.email.dirty && validation.email.invalid" class="help-block">
        <span v-if="validation.email.required">入力してください。</span>
        <span v-if="!validation.email.required && validation.email.email">無効なメールアドレスです。</span>
      </span>
    </div>

    <div v-class="has-error: validation.password.dirty && validation.password.invalid" class="form-group password required user_password">
      <label class="password required control-label" for="user_password"><abbr title="required">*</abbr> パスワード</label>
      <input v-model="password" v-validate="required, minLength: 8" class="password required form-control" type="password" name="user[password]" id="user_password">
      <span v-if="validation.password.dirty && validation.password.invalid" class="help-block">
        <span v-if="validation.password.required">入力してください。</span>
        <span v-if="validation.password.minLength">8文字以上で入力してください。</span>
      </span>
    </div>
    <input type="submit" name="commit" value="Login" class="btn btn-primary btn-block">
  </form>
</div>

</template>

<script lang="coffee" type="text/coffeescript">

session = require("../services/session.service")

module.exports =

  methods:
    onSubmit: (e) ->
      e.preventDefault()

      $.each(@validation, (i, attr) ->
        attr.dirty = true
      )

      if @valid
        $.ajax(
          url: "#{App.env.apiHost}/v1/sessions"
          method: "POST"
          data:
            email: @email
            password: @password
        ).done((data, textStatus, jqXHR) =>

          session.setUser(data)
          @$dispatch("changeCurrentUser")
          page("/tasks")
          @$dispatch('Layout:flash', {class: 'alert-info', message: 'ログインしました。'})

        ).fail((jqXHR, textStatus, errorThrown) ->
          alert "ログインに失敗しました"
        )

  validator:
    validates:
      email: (val) ->
        return /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(val)

</script>
