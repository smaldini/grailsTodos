package todosample

import grails.converters.JSON

class TodosController {

    def list() {
        def todos = Todo.findAll() as JSON

        if (request.getHeader('X-Requested-With') == 'XMLHttpRequest')
            render(todos)
        else {
            render view: 'index', model: [todos: todos]
        }
    }

    def save() {
        def todo = new Todo(request.JSON)
        todo.save()
        render(todo as JSON)
    }

    def delete() {
        def todo = Todo.get(params.id)
        todo?.delete()
        if (todo) {
            render(todo as JSON)
        } else {
            response.sendError(403)
        }
    }

    def edit() {
        def todo = Todo.get(params.id)
        if (todo) {
            bindData(todo, request.JSON)
            render(todo.save() as JSON)
        } else {
            response.sendError(403)
        }

    }


}
