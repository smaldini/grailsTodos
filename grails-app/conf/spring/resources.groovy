// Place your Spring DSL code here
beans = {
    xmlns si: 'http://www.springframework.org/schema/integration'
    //xmlns siRedis: "http://www.springframework.org/schema/integration/redis"
    xmlns siAmqp: "http://www.springframework.org/schema/integration/amqp"

    //siRedis.'publish-subscribe-channel'(id:'grailsTopicTest' , 'topic-name':'si.test.topic')
    /*
     redisConnectionFactory(org.springframework.data.redis.connection.jedis.JedisConnectionFactory)
    redisTemplate(org.springframework.data.redis.core.RedisTemplate){
        connectionFactory = ref('redisConnectionFactory')
    }
     */

    errorsAmqp(amqp.DumpAmqpErrors)

    //si.filter(id:'bugger','input-channel': 'grailsPipeline', 'output-channel':'nullChannel', expression: 'payload.entityObject.scope == "blah"')

    siAmqp.channel(id:'afterInsert','connection-factory':'rabbitMQConnectionFactory', 'error-handler':"errorsAmqp")
    siAmqp.channel(id:'afterDelete','connection-factory':'rabbitMQConnectionFactory', 'error-handler':"errorsAmqp")
    siAmqp.channel(id:'afterUpdate','connection-factory':'rabbitMQConnectionFactory', 'error-handler':"errorsAmqp")

//    siAmqp.channel(id:'saveTodo','connection-factory':'rabbitMQConnectionFactory')

    //siAmqp.'publish-subscribe-channel'(id:'grailsTopicTest', )


}
