import todosample.Todo

events = {
    'afterInsert' browser:true, namespace:'gorm', filter:Todo
    'afterDelete' browser:true, namespace:'gorm', filter:Todo
    'afterUpdate' browser:true, namespace:'gorm', filter:Todo
}