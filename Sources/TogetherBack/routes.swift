import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Together API is running."
    }

    try app.register(collection: UserController())
    try app.register(collection: CoupleController())
    try app.register(collection: ActivityController())
    try app.register(collection: PlannedActivityController())

}
