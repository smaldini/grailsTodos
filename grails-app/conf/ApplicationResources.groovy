modules = {
    todos{
        dependsOn 'backbone, underscore, jquery, grailsEvents'
        resource url: 'js/todos.coffee'
        resource url: 'css/todos.css'
    }
    backbone {
        resource url: 'js/backbone-min.js'
    }
    underscore {
        resource url: 'js/underscore-min.js'
    }
}