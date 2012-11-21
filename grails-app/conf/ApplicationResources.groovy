modules = {
    todos{
        dependsOn 'backbone, underscore, jquery, grailsEvents'
        resource url: 'js/todos.coffee'
        resource url: 'css/todos.css'
    }
    game{
        dependsOn 'jquery, grailsEvents'
        resource url: 'js/animation/easeljs-0.5.0.min.js'
    }
    backbone {
        resource url: 'js/backbone-min.js'
    }
    underscore {
        resource url: 'js/underscore-min.js'
    }
}