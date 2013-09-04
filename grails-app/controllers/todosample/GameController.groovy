package todosample

/**
 * @file
 * @author Stephane Maldini <smaldini@vmware.com>
 * @version 1.0
 * @date 21/11/2012

 * @section DESCRIPTION
 *
 * [Does stuff]
 */
class GameController {

    def board(String playerName) {
        if (!playerName) {
            render 'Please use the following URL format: http://.../game/[Your user name]'
            return
        }


    }
}
