var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

_.templateSettings = {
  interpolate: /\{\{(.+?)\}\}/g,
  evaluate: /\{!(.+?)!\}/g
};

$(function() {
  var AppView, TodoList, TodoView;
  window.TodoRouter = (function(_super) {

    __extends(TodoRouter, _super);

    function TodoRouter() {
      return TodoRouter.__super__.constructor.apply(this, arguments);
    }

    TodoRouter.prototype.routes = {
      "/posts/:id": "getPost"
    };

    TodoRouter.prototype.getPost = function(id) {
      return alert("Get post number " + id);
    };

    return TodoRouter;

  })(Backbone.Router);
  window.app_router = new TodoRouter;
  Backbone.history.start();
  /* Todo Model
  */

  window.Todo = (function(_super) {

    __extends(Todo, _super);

    function Todo() {
      return Todo.__super__.constructor.apply(this, arguments);
    }

    Todo.prototype.defaults = {
      content: "empty todo...",
      done: false
    };

    Todo.prototype.initialize = function() {
      if (!this.get("content")) {
        return this.set({
          "content": this.defaults.content
        });
      }
    };

    Todo.prototype.toggle = function() {
      return this.save({
        done: !this.get("done")
      });
    };

    Todo.prototype.clear = function() {
      return this.destroy();
    };

    return Todo;

  })(Backbone.Model);
  /* Todo Collection
  */

  TodoList = (function(_super) {
    var getDone;

    __extends(TodoList, _super);

    function TodoList() {
      return TodoList.__super__.constructor.apply(this, arguments);
    }

    TodoList.prototype.model = Todo;

    TodoList.prototype.url = 'todos';

    getDone = function(todo) {
      return todo.get("done");
    };

    TodoList.prototype.done = function() {
      return this.filter(getDone);
    };

    TodoList.prototype.remaining = function() {
      return this.without.apply(this, this.done());
    };

    TodoList.prototype.nextOrder = function() {
      if (!this.length) {
        return 1;
      }
      return this.last().get('order') + 1;
    };

    TodoList.prototype.comparator = function(todo) {
      return todo.get("order");
    };

    return TodoList;

  })(Backbone.Collection);
  /* Todo Item View
  */

  TodoView = (function(_super) {

    __extends(TodoView, _super);

    function TodoView() {
      this.destroy = __bind(this.destroy, this);

      this.updateOnEnter = __bind(this.updateOnEnter, this);

      this.close = __bind(this.close, this);

      this.edit = __bind(this.edit, this);

      this.render = __bind(this.render, this);
      return TodoView.__super__.constructor.apply(this, arguments);
    }

    TodoView.prototype.tagName = "li";

    TodoView.prototype.template = _.template($("#item-template").html());

    TodoView.prototype.events = {
      "click .check": "toggleDone",
      "dblclick div.todo-content": "edit",
      "click span.todo-destroy": "destroy",
      "keypress .todo-input": "updateOnEnter"
    };

    TodoView.prototype.initialize = function() {
      this.model.bind('change', this.render);
      return Todos.bind('remove', this.remove, this);
    };

    TodoView.prototype.render = function() {
      this.$el.html(this.template(this.model.toJSON()));
      this.setContent();
      return this;
    };

    TodoView.prototype.setContent = function() {
      var content;
      content = this.model.get("content");
      this.$(".todo-content").text(content);
      this.input = this.$(".todo-input");
      this.input.bind("blur", this.close);
      return this.input.val(content);
    };

    TodoView.prototype.toggleDone = function() {
      return this.model.toggle();
    };

    TodoView.prototype.edit = function() {
      this.$el.addClass("editing");
      return this.input.focus();
    };

    TodoView.prototype.close = function() {
      this.model.save({
        content: this.input.val()
      });
      return this.$el.removeClass("editing");
    };

    TodoView.prototype.updateOnEnter = function(e) {
      if (e.keyCode === 13) {
        return this.close();
      }
    };

    TodoView.prototype.remove = function(e) {
      if (!e || e === this.model) {
        return this.$el.remove();
      }
    };

    TodoView.prototype.destroy = function() {
      return this.model.destroy();
    };

    return TodoView;

  })(Backbone.View);
  /* The Application
  */

  AppView = (function(_super) {
    var el_tag;

    __extends(AppView, _super);

    function AppView() {
      this.addAll = __bind(this.addAll, this);

      this.addOne = __bind(this.addOne, this);

      this.render = __bind(this.render, this);

      this.initialize = __bind(this.initialize, this);
      return AppView.__super__.constructor.apply(this, arguments);
    }

    el_tag = "#todoapp";

    AppView.prototype.el = $(el_tag);

    AppView.prototype.statsTemplate = _.template($("#stats-template").html());

    AppView.prototype.events = {
      "keypress #new-todo": "createOnEnter",
      "keyup #new-todo": "showTooltip",
      "click .todo-clear a": "clearCompleted"
    };

    AppView.prototype.initialize = function() {
      this.input = this.$("#new-todo");
      Todos.bind("add", this.addOne);
      Todos.bind("reset", this.addAll);
      return Todos.bind("all", this.render);
    };

    AppView.prototype.render = function() {
      return this.$('#todo-stats').html(this.statsTemplate({
        total: Todos.length,
        done: Todos.done().length,
        remaining: Todos.remaining().length
      }));
    };

    AppView.prototype.addOne = function(todo) {
      var view;
      view = new TodoView({
        model: todo
      });
      return this.$("#todo-list").append(view.render().el);
    };

    AppView.prototype.addAll = function() {
      return Todos.each(this.addOne);
    };

    AppView.prototype.newAttributes = function() {
      return {
        content: this.input.val(),
        order: Todos.nextOrder(),
        done: false
      };
    };

    AppView.prototype.createOnEnter = function(e) {
      if (e.keyCode !== 13) {
        return;
      }
      Todos.create(this.newAttributes(), {
        wait: true
      });
      return this.input.val('');
    };

    AppView.prototype.clearCompleted = function() {
      _.each(Todos.done(), function(todo) {
        return todo.destroy();
      });
      return false;
    };

    AppView.prototype.showTooltip = function(e) {
      var show, tooltip, val;
      tooltip = this.$(".ui-tooltip-top");
      val = this.input.val();
      tooltip.fadeOut();
      if (this.tooltipTimeout) {
        clearTimeout(this.tooltipTimeout);
      }
      if (val === '' || val === this.input.attr("placeholder")) {
        return;
      }
      show = function() {
        return tooltip.show().fadeIn();
      };
      return this.tooltipTimeout = _.delay(show, 1000);
    };

    return AppView;

  })(Backbone.View);
  window.Todos = new TodoList;
  window.App = new AppView;
  return Todos.reset(window.todos);
});