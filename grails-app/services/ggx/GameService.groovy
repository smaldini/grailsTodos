package ggx

import grails.events.Listener

/**
 * Author: smaldini
 * Date: 11/21/12
 * Project: redisEvents
 */
class GameService {

    @Listener(namespace='browser')
    void fire(evt){
        log.info evt
    }
}
