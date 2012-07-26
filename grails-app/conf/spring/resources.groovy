// Place your Spring DSL code here
beans = {
    xmlns si: 'http://www.springframework.org/schema/integration'
    xmlns siAmqp: "http://www.springframework.org/schema/integration/amqp"


    errorsAmqp(amqp.DumpAmqpErrors)


    siAmqp.'publish-subscribe-channel'(id: 'gorm://afterInsert', 'connection-factory': 'rabbitMQConnectionFactory', 'error-handler': "errorsAmqp")
    siAmqp.'publish-subscribe-channel'(id: 'gorm://afterDelete', 'connection-factory': 'rabbitMQConnectionFactory', 'error-handler': "errorsAmqp")
    siAmqp.'publish-subscribe-channel'(id: 'gorm://afterUpdate', 'connection-factory': 'rabbitMQConnectionFactory', 'error-handler': "errorsAmqp")


}
