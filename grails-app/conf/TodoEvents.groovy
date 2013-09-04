import todosample.Todo

events = {
    'afterInsert' browser: true, namespace: 'gorm', filter: Todo
    'afterDelete' browser: true, namespace: 'gorm', filter: Todo
    'afterUpdate' browser: true, namespace: 'gorm', filter: Todo

    "move" namespace: 'browser', browser: true
    "fire" namespace: 'browser', browser: true
    "leave" namespace: 'browser', browser: true

}


//springIntegrationModules = ['amqp']
//springIntegration = {
//
//    channel('gorm://afterUpdate')
//
////    springXml {
////        'bean'(id:'test', class:Todo)
////        'int-amqp:publish-subscribe-channel'(
////                id: 'gorm://afterUpdate',
////                'channel-transacted': false,
////                'connection-factory': 'rabbitMQConnectionFactory'
////        )
////    }
//
//    messageFlow(inputChannel:'gorm://afterUpdate', outputChannel:'gorm://afterUpdate-local') {
//        handle{ println it ; it}
//    }
//}