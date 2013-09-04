package ggx

import reactor.spring.annotation.Selector

/**
 * Author: smaldini
 * Date: 11/21/12
 * Project: redisEvents
 */
class GameService {

    @Selector(reactor='browser')
    void fire(evt){
        log.info evt
    }
}
