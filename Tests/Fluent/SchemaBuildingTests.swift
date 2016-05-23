import Foundation
import XCTest
import Reflection
//import Fluent
@testable import Fluent

class SchemaBuildingTests: XCTestCase {
    class Foo: Model {
        var id: Value?
        func serialize() -> [String:Value?] { return ["id":id] }
        required init?(serialized d: [String:Value]) { self.id = d["id"] }
    }
    
    class Baz: Model {
        var id: Value?
        func serialize() -> [String:Value?] { return ["id":id] }
        required init?(serialized d: [String:Value]) { self.id = d["id"] }
    }
    
    class Bar: Model {
        var id: Value?
        var foos = [Foo]()
        func serialize() -> [String: Value?] { return ["id":id] }
        required init?(serialized d: [String:Value]) { self.id = d["id"] }
    }
    
    func testInspectProperties() {
        let table = Table(entityType: Bar.self)
        let foos = table.columns["foos"]!
        
        if case let .relationship(_, columnType) = foos {
            XCTAssertTrue(columnType is Foo.Type)
            XCTAssertFalse(columnType is Bar.Type)
        }
        
        print(table)
    }
}