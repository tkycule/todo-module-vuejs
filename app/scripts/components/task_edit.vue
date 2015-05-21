<template>
<h2>タスク編集</h2>
<div class="well">
  <form class="edit_task" name="taskForm" v-on="submit: onSubmit($event)" novalidate="novalidate">

    <div class="form-group string required task_title" v-class="has-error: (validation['task.title'].dirty && validation['task.title'].invalid)">
      <label class="control-label" for="task_title">
        <abbr title="required">*</abbr>
        タイトル
      </label>
      <input v-model="task.title" v-validate="required" class="form-control" type="text" name="title" id="task_title">
      <span v-if="validation['task.title'].dirty" class="help-block">
        <span v-if="validation['task.title'].required">入力してください。</span>
      </span>
    </div>

    <div class="form-group text optional task_memo">
      <label class="control-label" for="task_memo">メモ</label>
      <textarea class="form-control" id="task_memo" v-model="task.memo"></textarea>
    </div>
    <input type="submit" name="commit" value="Save" class="btn btn-primary btn-block">
  </form>
</div>
</template>

<script lang="coffee" type="text/coffeescript">

module.exports =

  inherit: true

  data: ->
    task: {}

  created: ->
    $.ajax(
      url: "#{App.env.apiHost}/v1/tasks/#{@id}"
    ).done( (data) =>
      @task = data
    )

  methods:
    onSubmit: (e) ->
      e.preventDefault()

      $.each(@validation, (i, attr) ->
        attr.dirty = true
      )

      if @valid
        $.ajax(
          url: "#{App.env.apiHost}/v1/tasks/#{@id}"
          method: "PUT"
          data: {task: @task}
        ).done( =>
          page("/tasks")
          @$dispatch('Layout:flash', {class: 'alert-info', message: '更新しました。'})
        )
</script>
