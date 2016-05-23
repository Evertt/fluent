//
//  SchemaBuilder.swift
//  Fluent
//
//  Created by Evert van Brussel on 19/05/16.
//
//

import Foundation

public enum Relationship: String {
    case hasOne, belongsTo, hasMany, belongsToMany
}

public enum ColumnType {
    case value(Value.Type)
    case relationship(Relationship, Model.Type)
}

public struct Table {
    public let columns: [String:ColumnType]
    
    public init(columns: [String:ColumnType]) {
        self.columns = columns
    }
    
    init(entityType: Model.Type) {
        let entity = entityType.init(serialized: [:])!
        let entityMirror = Mirror(reflecting: entity)
        var columns = [String:ColumnType]()
        
        for child in entityMirror.children {
            if let property = child.label {
                switch child.value {
                case let array as WrappedInArray where array.elementType is Model.Type:
                    columns[property] = ColumnType.relationship(.hasMany, array.elementType as! Model.Type)
                case let optional as WrappedInOptional where optional.elementType is Model.Type:
                    columns[property] = ColumnType.relationship(.belongsTo, optional.elementType as! Model.Type)
                case let relatedEntity as Model:
                    columns[property] = ColumnType.relationship(.belongsTo, relatedEntity.dynamicType)
                case let optional as WrappedInOptional where optional.elementType is Value.Type:
                    columns[property] = ColumnType.value(optional.elementType as! Value.Type)
                case let value as Value:
                    columns[property] = ColumnType.value(value.dynamicType)
                default: continue
                }
            }
        }
        
        self.init(columns: columns)
    }
}

protocol TypeExtracting {
    var elementType: Any.Type { get }
}

protocol WrappedInArray: TypeExtracting {}
protocol WrappedInOptional: TypeExtracting {}

extension Array: WrappedInArray {
    var elementType: Any.Type {
        return Element.self
    }
}

extension Optional: WrappedInOptional {
    var elementType: Any.Type {
        return Wrapped.self
    }
}








