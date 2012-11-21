class UrlMappings {

    static mappings = {
        "/$controller/$action?/$id?" {
            constraints {
                // apply constraints here
            }
        }

        "/todos/$id?"(controller: "todos") {
            action = [GET: "list", POST: "save", DELETE: "delete", PUT: "edit"]
        }

        "/"(view: "/index")
        "/game/$playerName"(view: "/game")
        "500"(view: '/error')
    }
}
