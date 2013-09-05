package amqp

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.util.ErrorHandler

/**
 * @file
 * @author Stephane Maldini <smaldini@gopivotal.com>
 * @version 1.0
 * @date 26/05/12

 * @section DESCRIPTION
 *
 * [Does stuff]
 */
class DumpAmqpErrors implements ErrorHandler{
    /** Field description */
    final static Logger logger = LoggerFactory.getLogger(DumpAmqpErrors)

    //~--- methods ------------------------------------------------------------

    /**
     * Handle the given error, possibly rethrowing it as a fatal exception
     *
     * @param t
     */
    public void handleError(Throwable t) {
        logger.error("unexpected messaging error", t)
    }
}
