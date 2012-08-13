// Place your Spring DSL code here
beans = {
    xmlns si: 'http://www.springframework.org/schema/integration'
    xmlns siAmqp: "http://www.springframework.org/schema/integration/amqp"
    xmlns rabbit: "http://www.springframework.org/schema/rabbit"


    errorsAmqp(amqp.DumpAmqpErrors)


    siAmqp.'publish-subscribe-channel'(id: 'gorm://afterInsert', 'channel-transacted':false,
            'connection-factory': 'rabbitMQConnectionFactory', 'error-handler': "errorsAmqp")

    siAmqp.'publish-subscribe-channel'(id: 'gorm://afterDelete', 'channel-transacted':false,
            'connection-factory': 'rabbitMQConnectionFactory', 'error-handler': "errorsAmqp")

    siAmqp.'publish-subscribe-channel'(id: 'gorm://afterUpdate', 'channel-transacted':false,
            'connection-factory': 'rabbitMQConnectionFactory', 'error-handler': "errorsAmqp")


}
