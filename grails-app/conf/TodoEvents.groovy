import org.grails.plugin.platform.events.push.SharedConstants
import todosample.Todo


doWithReactor = {

	reactor('grailsReactor') {
		ext 'gorm', true
		ext 'browser', ['afterInsert', 'afterDelete', 'afterUpdate']
	}

	reactor(SharedConstants.PUSH_SCOPE) {
		ext 'browser', ['move', 'fire', 'leave']
	}
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