<template>

<div class="row">
  <div class="col-sm-2" id="sidebar">
    <h3>収集</h3>
    <ul class="list-unstyled">
      <li v-class="current: state == 'inbox'">
        <a class="clearfix" href="/tasks">
          <div class="pull-left">
            <i class="glyphicon glyphicon-inbox"></i>
            収集箱
          </div>
          <div class="pull-right inbox-count">{{task_count["inbox"]}}</div>
        </a>
      </li>
    </ul>
    <h3>終了</h3>
    <ul class="list-unstyled">
      <li v-class="current: state == 'completed'">
        <a class="clearfix" href="/tasks/completed">
          <div class="pull-left">
            <i class="glyphicon glyphicon-ok-sign"></i>
            完了
          </div>
          <div class="pull-right completed-count">{{task_count["completed"]}}</div>
        </a>
      </li>
      <li v-class="current: state == 'deleted'">
        <a class="clearfix" href="/tasks/deleted">
          <div class="pull-left">
            <i class="glyphicon glyphicon-trash"></i>
            ゴミ箱
          </div>
          <div class="pull-right deleted-count">{{task_count["deleted"]}}</div>
        </a>
      </li>
    </ul>
  </div>
  <div class="col-sm-10">
    <form id="new_task" class="new_task" v-on="submit: onSubmit($event)">
      <div class="input-group">
        <input class="form-control" placeholder="タスク" type="text" id="task_title" v-model="new_task_title">
        <span class="input-group-btn">
          <input type="submit" name="commit" value="登録" class="btn btn-success">
        </span>
      </div>
    </form>

    <ul class="list-unstyled" id="tasks">
      <li class="task clearfix" v-repeat="tasks | filterBy state in aasm_state | orderBy 'id' -1">
        <div class="pull-left">
          <a href="/tasks/{{id}}/edit">{{title}}</a>
        </div>
        <div class="pull-right">
          <a v-on="click: action('done', this)" v-if="aasm_state == 'inbox'" class="task-complete btn btn-primary">完了</a>
          <a v-on="click: action('revert', this)" v-if="aasm_state != 'inbox'" class="task-revert btn btn-default">戻す</a>
          <a v-on="click: action('delete', this)" v-if="aasm_state != 'deleted'" class="task-delete btn btn-danger">削除</a>
        </div>
      </li>
    </ul>
  </div>
</div>
  
</template>

<script lang="coffee" type="text/coffeescript">

module.exports =

  data: ->
    tasks: []
    state: App.state

  computed:
    task_count: ->
      count = {"inbox": 0, "completed": 0, "deleted": 0}
      $.each(@tasks, -> count[this.aasm_state]++ )
      return count

  created: ->

    $.ajax(
      url: "#{App.env.apiHost}/v1/tasks"
    ).done( (data, textStatus, jqXHR) =>
      @tasks = data
    )

    @$on("changeState", =>
      @state = App.state
    )

  methods:
    action: (action, task) ->
      acts =
        done:
          url: "#{task.id}/complete"
          method: "PUT"
          flash: {class: 'alert-info', message: '完了にしました。'}
        delete:
          url: "#{task.id}"
          method: "DELETE"
          flash: {class: 'alert-info', message: 'ゴミ箱に入れました。'}
        revert:
          url: "#{task.id}/revert"
          method: "PUT"
          flash: {class: 'alert-info', message: '収集箱に戻しました。'}

      act = acts[action]
      $.ajax(
        url: "#{App.env.apiHost}/v1/tasks/#{act.url}"
        method: act.method
      ).done( (data) =>
        task.aasm_state = data.aasm_state
        @$dispatch('Layout:flash', act.flash)
      )

    onSubmit: (e) ->
      e.preventDefault()
      if @new_task_title?.trim()
        $.ajax(
          url: "#{App.env.apiHost}/v1/tasks"
          method: "POST"
          data:
            task:
              title: @new_task_title
        ).done( (data) =>
          @new_task_title = ""
          @tasks.push(data)
          @$dispatch('Layout:flash', {class: 'alert-info', message: '作成しました。'})
        )
</script>
