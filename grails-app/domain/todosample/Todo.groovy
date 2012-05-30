package todosample

class Todo implements Serializable{

    boolean done
    int order
    String content

    static mapping = {
        order column: 'todo_order'
    }

    static constraints = {
        content(nullable: false, empty: false)
    }
}