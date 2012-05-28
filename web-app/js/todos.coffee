# An example Backbone application contributed by
# [Jérôme Gravel-Niquet](http://jgn.me/).
#
# This [CoffeeScript](http://jashkenas.github.com/coffee-script/) variation has been provided by [Jason Giedymin](http://jasongiedymin.com/).

# Load the application once the DOM is ready, using a `jQuery.ready` shortcut.
_.templateSettings =
            interpolate: /\{\{(.+?)\}\}/g
            evaluate: /\{!(.+?)!\}/g

$ ->
    # Todo Router
    # ----------

    class window.TodoRouter extends Backbone.Router
        routes:
            "/posts/:id": "getPost"
        #    "*actions": "defaultRoute"

        getPost: (id) ->
            alert "Get post number " + id

        #defaultRoute: (actions) ->
        #    alert actions

    window.app_router = new TodoRouter
    Backbone.history.start()


    ### Todo Model ###

    # Our basic **Todo** model has `content`, `order`, and `done` attributes.
    class window.Todo extends Backbone.Model
        # Default attributes for the todo.
        defaults:
            content: "empty todo..."
            done: false

        # Ensure that each todo created has `content`.
        initialize: ->
            if !@get("content")
                @set({ "content": @defaults.content })

        # Toggle the `done` state of this todo item.
        toggle: ->
            @save({ done: !@get("done") })

        # Remove this Todo from *localStorage* and delete its view.
        clear: ->
            @destroy()

    ### Todo Collection ###

    # The collection of todos is backed by *localStorage* instead of a remote
    # server.
    class TodoList extends Backbone.Collection

        # Reference to this collection's model.
        model: Todo

        # Save all of the todo items under the `"todos"` namespace.
        url: 'todos'

        # Attribute getter/setter
        getDone = (todo) ->
            return todo.get("done")

        # Filter down the list of all todo items that are finished.
        done: ->
            return @filter( getDone )

        # Filter down the list to only todo items that are still not finished.
        remaining: ->
            return @without.apply( this, @done() )

        # We keep the Todos in sequential order, despite being saved by unordered
        # GUID in the database. This generates the next order number for new items.
        nextOrder: ->
            return 1 if !@length
            return @last().get('order') + 1

        # Todos are sorted by their original insertion order.
        comparator: (todo) ->
            return todo.get("order")

    ### Todo Item View ###

    # The DOM element for a todo item...
    class TodoView extends Backbone.View

        #... is a list tag.
        tagName:  "li"

        # Cache the template function for a single item.
        template: _.template( $("#item-template").html() )

        # The DOM events specific to an item.
        events:
            "click .check"              : "toggleDone",
            "dblclick div.todo-content" : "edit",
            "click span.todo-destroy"   : "destroy",
            "keypress .todo-input"      : "updateOnEnter"

        initialize: ->
            @model.bind('change', @render)
            Todos.bind('remove', @remove, @)

        # Re-render the contents of the todo item.
        render: =>
            this.$el.html(@template(@model.toJSON()))
            @setContent()
            return this

        # To avoid XSS (not that it would be harmful in this particular app),
        # we use `jQuery.text` to set the contents of the todo item.
        setContent: ->
            content = @model.get("content")
            this.$(".todo-content").text(content)
            @input = this.$(".todo-input")
            @input.bind("blur", @close)
            @input.val(content)

        # Toggle the `"done"` state of the model.
        toggleDone: ->
            @model.toggle()

        # Switch this view into `"editing"` mode, displaying the input field.
        edit: =>
            this.$el.addClass("editing")
            @input.focus()

        # Close the `"editing"` mode, saving changes to the todo.
        close: =>
            @model.save({content: @input.val()})
            this.$el.removeClass("editing")

        # If you hit `enter`, we're through editing the item.
        updateOnEnter: (e) =>
            @close() if e.keyCode is 13

        # Remove this view from the DOM.
        remove: (e)->
            this.$el.remove() if !e || e == @model

        # Remove the item, destroy the model.
        destroy: () =>
            @model.destroy()

    ### The Application ###

    # Our overall **AppView** is the top-level piece of UI.
    class AppView extends Backbone.View
        # Instead of generating a new element, bind to the existing skeleton of
        # the App already present in the HTML.
        el_tag = "#todoapp"
        el: $(el_tag)

        # Our template for the line of statistics at the bottom of the app.
        statsTemplate: _.template( $("#stats-template").html() )

        # Delegated events for creating new items, and clearing completed ones.
        events:
            "keypress #new-todo"  : "createOnEnter",
            "keyup #new-todo"     : "showTooltip",
            "click .todo-clear a" : "clearCompleted"

        # At initialization we bind to the relevant events on the `Todos`
        # collection, when items are added or changed. Kick things off by
        # loading any preexisting todos that might be saved in *localStorage*.
        initialize: =>
            @input = this.$("#new-todo")

            Todos.bind("add", @addOne)
            Todos.bind("reset", @addAll)
            Todos.bind("all", @render)

            #Todos.fetch()

        # Re-rendering the App just means refreshing the statistics -- the rest
        # of the app doesn't change.
        render: =>
            this.$('#todo-stats').html( @statsTemplate({
                total:      Todos.length,
                done:       Todos.done().length,
                remaining:  Todos.remaining().length
            }))

        # Add a single todo item to the list by creating a view for it, and
        # appending its element to the `<ul>`.
        addOne: (todo) =>
            view = new TodoView( {model: todo} )
            this.$("#todo-list").append( view.render().el )

        # Add all items in the **Todos** collection at once.
        addAll: =>
            Todos.each(@addOne)

        # Generate the attributes for a new Todo item.
        newAttributes: ->
            return {
                content: @input.val(),
                order:   Todos.nextOrder(),
                done:    false
            }

        # If you hit return in the main input field, create new **Todo** model,
        # persisting it to *localStorage*.
        createOnEnter: (e) ->
            return if (e.keyCode != 13)
            Todos.create(@newAttributes(), {wait: true});
            @input.val('')

        # Clear all done todo items, destroying their models.
        clearCompleted: ->
            _.each(Todos.done(), (todo) ->
                todo.destroy()
            )
            return false

        # Lazily show the tooltip that tells you to press `enter` to save
        # a new todo item, after one second.
        showTooltip: (e) ->
            tooltip = this.$(".ui-tooltip-top")
            val = @input.val()
            tooltip.fadeOut()
            clearTimeout(@tooltipTimeout) if (@tooltipTimeout)
            return if (val is '' || val is @input.attr("placeholder"))

            show = () ->
                tooltip.show().fadeIn()
            @tooltipTimeout = _.delay(show, 1000)

    # Create our global collection of **Todos**.
    # Note: I've actually chosen not to export globally to `window`.
    # Original documentation has been left intact.
    window.Todos = new TodoList
    window.App = new AppView
    Todos.reset window.todos


        