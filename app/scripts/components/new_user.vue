<template>

<h1>新規登録</h1>

<div class="well">
  <form v-on="submit: onSubmit($event)" id="new_user" name="newUserForm" novalidate="novalidate">

    <div class="form-group email required user_email" v-class="has-error: (validation['user.email'].dirty && validation['user.email'].invalid)">
      <label class="control-label" for="user_email">
        <abbr title="required">*</abbr>
        メールアドレス
      </label>
      <input v-model="user.email" v-validate="required" id="user_email" class="form-control" type="email" name="email" />
      <span v-if="validation['user.email'].dirty" class="help-block">
        <span v-if="validation['user.email'].required">入力してください。</span>
        <span v-if="validation['user.email'].email">無効なメールアドレスです。</span>
      </span>
    </div>

    <div class="form-group password required user_password" v-class="has-error: (validation['user.password'].dirty && validation['user.password'].invalid)">
      <label class="control-label" for="user_password">
        <abbr title="required">*</abbr>
        パスワード
      </label>
      <input v-model="user.password" v-validate="required, minLength:8" id="user_password" class="form-control" type="password" name="password" />
      <span v-if="validation['user.password'].dirty" class="help-block">
        <span v-if="validation['user.password'].required">入力してください。</span>
        <span v-if="validation['user.password'].minLength">8文字以上で入力してください。</span>
      </span>
    </div>

    <div class="form-group password required user_password_confirmation" v-class="has-error: (validation['user.password_confirmation'].dirty && validation['user.password_confirmation'].invalid)">

      <label class="control-label" for="user_password_confirmation">
        <abbr title="required">*</abbr>
        パスワード(確認)
      </label>

      <input id="user_password_confirmation" class="form-control" type="password" name="password_confirmation"
        v-model="user.password_confirmation" v-validate="required, minLength:8, compareTo: user.password"/>

      <span v-if="validation['user.password_confirmation'].dirty" class="help-block">
        <span v-if="validation['user.password_confirmation'].required">入力してください。</span>
        <span v-if="validation['user.password_confirmation'].minLength">8文字以上で入力してください。</span>
        <span v-if="validation['user.password_confirmation'].compareTo">パスワードが一致しません。</span>
      </span>
    </div>

    <input type="submit" value="Save" class="btn btn-primary btn-block">
  </form>
</div>
  
</template>

<script lang="coffee" type="text/coffeescript">

session = require("../services/session.service")

module.exports =

  data: ->
    user: {}

  validator:
    validates:
      compareTo: (value, target) ->

        targetValue = @$parent.$data
        $.each(target.split("."), (i, attr) ->
          targetValue = targetValue[attr]
        )

        return value == targetValue

  methods:
    onSubmit: (e) ->
      e.preventDefault()

      $.each(@validation, (i, attr) ->
        attr.dirty = true
      )

      if @valid
        $.ajax(
          url: "#{App.env.apiHost}/v1/users"
          method: "POST"
          data: @$data
        ).done( (data) =>

          session.setUser(data)
          page("/tasks")
          @$dispatch("changeCurrentUser")

        ).fail( (jqXHR, textStatus, errorThrown) ->

          alert JSON.parse(jqXHR.responseText).join("\n")
        )

</script>
