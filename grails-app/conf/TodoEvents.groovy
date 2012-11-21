import todosample.Todo

events = {
    'afterInsert' browser: true, namespace: 'gorm', filter: Todo
    'afterDelete' browser: true, namespace: 'gorm', filter: Todo
    'afterUpdate' browser: true, namespace: 'gorm', filter: Todo

    "move" namespace: 'browser', browser: true //Will allow client to register for events push
    "fire" namespace: 'browser', browser: true //Will allow client to register for events push
    "leave" namespace: 'browser', browser: true //Will allow client to register for events push

}