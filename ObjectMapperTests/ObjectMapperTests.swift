//
//  ObjectMapperTests.swift
//  ObjectMapperTests
//
//  Created by Tristan Himmelman on 2014-10-16.
//  Copyright (c) 2014 hearst. All rights reserved.
//

import Foundation
import XCTest
import ObjectMapper
import Nimble

class ObjectMapperTests: XCTestCase {

    let userMapper = Mapper<User>()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testImmutableMappable() {
		let mapper = Mapper<Immutable>()
		let JSON = [ "prop1": "Immutable!", "prop2": 255, "prop3": true ]

		let immutable: Immutable! = mapper.map(JSON)
		expect(immutable).notTo(beNil())
		expect(immutable?.prop1).to(equal("Immutable!"))
		expect(immutable?.prop2).to(equal(255))
		expect(immutable?.prop3).to(equal(true))

		let JSON2 = [ "prop1": "prop1", "prop2": NSNull() ]
		let immutable2 = mapper.map(JSON2)
		expect(immutable2).to(beNil())

		let JSONFromObject = mapper.toJSON(immutable)
		expect(mapper.map(JSONFromObject)).to(equal(immutable))
	}

    func testBasicParsing() {
        let username = "John Doe"
        let identifier = "user8723"
        let photoCount = 13
        let age = 1227
        let weight = 123.23
        let float: Float = 123.231
        let drinker = true
        let smoker = false
        let arr = [ "bla", true, 42 ]
        let directory = [
            "key1" : "value1",
            "key2" : false,
            "key3" : 142
        ]
        
        let subUserJSON = "{\"identifier\" : \"user8723\", \"drinker\" : true, \"age\": 17, \"username\" : \"sub user\" }"
        
        let userJSONString = "{\"username\":\"\(username)\",\"identifier\":\"\(identifier)\",\"photoCount\":\(photoCount),\"age\":\(age),\"drinker\":\(drinker),\"smoker\":\(smoker), \"arr\":[ \"bla\", true, 42 ], \"dict\":{ \"key1\" : \"value1\", \"key2\" : false, \"key3\" : 142 }, \"arrOpt\":[ \"bla\", true, 42 ], \"dictOpt\":{ \"key1\" : \"value1\", \"key2\" : false, \"key3\" : 142 }, \"weight\": \(weight), \"float\": \(float), \"friend\": \(subUserJSON), \"friendDictionary\":{ \"bestFriend\": \(subUserJSON)}}"

		let user = userMapper.map(userJSONString)!
		
		expect(user).notTo(beNil())
		expect(username).to(equal(user.username))
		expect(identifier).to(equal(user.identifier))
		expect(photoCount).to(equal(user.photoCount))
		expect(age).to(equal(user.age))
		expect(weight).to(equal(user.weight))
		expect(float).to(equal(user.float))
		expect(drinker).to(equal(user.drinker))
		expect(smoker).to(equal(user.smoker))

		//println(Mapper().toJSONString(user, prettyPrint: true))
    }

    func testInstanceParsing() {
        let username = "John Doe"
        let identifier = "user8723"
        let photoCount = 13
        let age = 1227
        let weight = 123.23
        let float: Float = 123.231
        let drinker = true
        let smoker = false
        let arr = [ "bla", true, 42 ]
        let directory = [
            "key1" : "value1",
            "key2" : false,
            "key3" : 142
        ]
        
        let subUserJSON = "{\"identifier\" : \"user8723\", \"drinker\" : true, \"age\": 17, \"username\" : \"sub user\" }"
        
        let userJSONString = "{\"username\":\"\(username)\",\"identifier\":\"\(identifier)\",\"photoCount\":\(photoCount),\"age\":\(age),\"drinker\":\(drinker),\"smoker\":\(smoker), \"arr\":[ \"bla\", true, 42 ], \"dict\":{ \"key1\" : \"value1\", \"key2\" : false, \"key3\" : 142 }, \"arrOpt\":[ \"bla\", true, 42 ], \"dictOpt\":{ \"key1\" : \"value1\", \"key2\" : false, \"key3\" : 142 },\"weight\": \(weight), \"float\": \(float), \"friend\": \(subUserJSON), \"friendDictionary\":{ \"bestFriend\": \(subUserJSON)}}"
        
        let user = Mapper().map(userJSONString, toObject: User())

		expect(username).to(equal(user.username))
		expect(identifier).to(equal(user.identifier))
		expect(photoCount).to(equal(user.photoCount))
		expect(age).to(equal(user.age))
		expect(weight).to(equal(user.weight))
		expect(float).to(equal(user.float))
		expect(drinker).to(equal(user.drinker))
		expect(smoker).to(equal(user.smoker))

        println(Mapper().toJSONString(user, prettyPrint: true))
    }
    
    func testDictionaryParsing() {
        var name: String = "Genghis khan"
        var UUID: String = "12345"
        var major: Int = 99
        var minor: Int = 1
        let json: [String: AnyObject] = ["name": name, "UUID": UUID, "major": major]
        
        //test that the sematics of value types works as expected.  the resulting maped student
        //should have the correct minor property set even thoug it's not mapped
        var s = Student()
        s.minor = minor
        let student = Mapper().map(json, toObject: s)

		expect(student.name).to(equal(name))
		expect(student.UUID).to(equal(UUID))
		expect(student.major).to(equal(major))
		expect(student.minor).to(equal(minor))

        //Test that mapping a reference type works as expected while not relying on the return value
        var username: String = "Barack Obama"
        var identifier: String = "Political"
        var photoCount: Int = 1000000000
        
        let json2: [String: AnyObject] = ["username": username, "identifier": identifier, "photoCount": photoCount]
        let user = User()
        Mapper().map(json2, toObject: user)
		expect(user.username).to(equal(username))
		expect(user.identifier).to(equal(identifier))
		expect(user.photoCount).to(equal(photoCount))
    }
    
	func testNullObject() {
		let JSONString = "{\"username\":\"bob\"}"

		let user = userMapper.map(JSONString)
		expect(user).notTo(beNil())
		expect(user?.age).to(beNil())
	}
	
	func testToObjectFromString() {
		let username = "bob"
		let JSONString = "{\"username\":\"\(username)\"}"
		
		var user = User()
		user.username = "Tristan"
		
		Mapper().map(JSONString, toObject: user)

		expect(user.username).to(equal(username))
	}
	
	func testToObjectFromJSON() {
		let username = "bob"
		let JSON = ["username": username]
		
		var user = User()
		user.username = "Tristan"
		
		Mapper().map(JSON, toObject: user)

		expect(user.username).to(equal(username))
	}
	
	func testToObjectFromAnyObject() {
		let username = "bob"
		let userJSON = ["username": username]
		
		var user = User()
		user.username = "Tristan"
		
		Mapper().map(userJSON as AnyObject?, toObject: user)

		expect(user.username).to(equal(username))
	}
	
    func testToJSONAndBack(){
        var user = User()
        user.username = "tristan_him"
        user.identifier = "tristan_him_identifier"
        user.photoCount = 0
        user.age = 28
        user.weight = 150
        user.drinker = true
        user.smoker = false
        user.arr = ["cheese", 11234]
        
        let JSONString = Mapper().toJSONString(user, prettyPrint: true)
        //println(JSONString)

		let parsedUser = userMapper.map(JSONString!)!
		expect(parsedUser).notTo(beNil())
		expect(user.identifier).to(equal(parsedUser.identifier))
		expect(user.photoCount).to(equal(parsedUser.photoCount))
		expect(user.age).to(equal(parsedUser.age))
		expect(user.weight).to(equal(parsedUser.weight))
		expect(user.drinker).to(equal(parsedUser.drinker))
		expect(user.smoker).to(equal(parsedUser.smoker))
    }

    func testUnknownPropertiesIgnored() {
        let JSONString = "{\"username\":\"bob\",\"identifier\":\"bob1987\", \"foo\" : \"bar\", \"fooArr\" : [ 1, 2, 3], \"fooObj\" : { \"baz\" : \"qux\" } }"

		let user = userMapper.map(JSONString)

		expect(user).notTo(beNil())
    }
    
    func testInvalidJsonResultsInNilObject() {
        let JSONString = "{\"username\":\"bob\",\"identifier\":\"bob1987\"" // missing ending brace

        let user = userMapper.map(JSONString)

		expect(user).to(beNil())
    }
	
	func testMapArrayJSON(){
		let name1 = "Bob"
		let name2 = "Jane"
		
		let JSONString = "[{\"name\": \"\(name1)\", \"UUID\": \"3C074D4B-FC8C-4CA2-82A9-6E9367BBC875\", \"major\": 541, \"minor\": 123},{ \"name\": \"\(name2)\", \"UUID\": \"3C074D4B-FC8C-4CA2-82A9-6E9367BBC876\", \"major\": 54321,\"minor\": 13 }]"
	
		let students = Mapper<Student>().mapArray(JSONString)

		expect(students).notTo(beEmpty())
		expect(students.count).to(equal(2))
		expect(students[0].name).to(equal(name1))
		expect(students[1].name).to(equal(name2))
	}

	// test mapArray() with JSON string that is not an array form
	// should return a collection with one item
	func testMapArrayJSONWithNoArray(){
		let name1 = "Bob"
		
		let JSONString = "{\"name\": \"\(name1)\", \"UUID\": \"3C074D4B-FC8C-4CA2-82A9-6E9367BBC875\", \"major\": 541, \"minor\": 123}"
		
		let students = Mapper<Student>().mapArray(JSONString)

		expect(students).notTo(beEmpty())
		expect(students.count).to(equal(1))
		expect(students[0].name).to(equal(name1))
	}

	func testArrayOfCustomObjects(){
		let percentage1: Double = 0.1
		let percentage2: Double = 1792.41
		
		let JSONString = "{ \"tasks\": [{\"taskId\":103,\"percentage\":\(percentage1)},{\"taskId\":108,\"percentage\":\(percentage2)}] }"
		
		let plan = Mapper<Plan>().map(JSONString)

		let tasks = plan?.tasks
		expect(tasks).notTo(beNil())
		expect(tasks?[0].percentage).to(equal(percentage1))
		expect(tasks?[1].percentage).to(equal(percentage2))
	}
	
	func testDictionaryOfCustomObjects(){
		let percentage1: Double = 0.1
		let percentage2: Double = 1792.41
		
		let JSONString = "{\"tasks\": { \"task1\": {\"taskId\":103,\"percentage\":\(percentage1)}, \"task2\": {\"taskId\":108,\"percentage\":\(percentage2)}}}"
		
		let taskDict = Mapper<TaskDictionary>().map(JSONString)
		
		let task = taskDict?.tasks?["task1"]
		expect(task).notTo(beNil())
		expect(task?.percentage).to(equal(percentage1))
	}
	
	func testDoubleParsing(){
		let percentage1: Double = 1792.41
		
		let JSONString = "{\"taskId\":103,\"percentage\":\(percentage1)}"
		
		let task = Mapper<Task>().map(JSONString)

		expect(task).notTo(beNil())
		expect(task?.percentage).to(equal(percentage1))
	}
	
	func testMappingAGenericObject(){
		let code: Int = 22
		let JSONString = "{\"result\":{\"code\":\(code)}}"
		
		let response = Mapper<Response<Status>>().map(JSONString)

		let status = response?.result?.status
		expect(status).notTo(beNil())
		expect(status).to(equal(code))
	}

	func testToJSONArray(){
		var task1 = Task()
		task1.taskId = 1
		task1.percentage = 11.1
		var task2 = Task()
		task2.taskId = 2
		task2.percentage = 22.2
		var task3 = Task()
		task3.taskId = 3
		task3.percentage = 33.3
		
		var taskArray = [task1, task2, task3]
		
		let JSONArray = Mapper().toJSONArray(taskArray)
		println(JSONArray)
		
		let taskId1 = JSONArray[0]["taskId"] as? Int
		let percentage1 = JSONArray[0]["percentage"] as? Double

		expect(taskId1).to(equal(task1.taskId))
		expect(percentage1).to(equal(task1.percentage))

		let taskId2 = JSONArray[1]["taskId"] as? Int
		let percentage2 = JSONArray[1]["percentage"] as? Double
		
		expect(taskId2).to(equal(task2.taskId))
		expect(percentage2).to(equal(task2.percentage))

		let taskId3 = JSONArray[2]["taskId"] as? Int
		let percentage3 = JSONArray[2]["percentage"] as? Double
		
		expect(taskId3).to(equal(task3.taskId))
		expect(percentage3).to(equal(task3.percentage))
	}
	
	func testSubclass() {
		var object = Subclass()
		object.base = "base var"
		object.sub = "sub var"
		
		let json = Mapper().toJSON(object)
		let parsedObject = Mapper<Subclass>().map(json)

		expect(object.base).to(equal(parsedObject?.base))
		expect(object.sub).to(equal(parsedObject?.sub))
	}

	func testGenericSubclass() {
		var object = GenericSubclass<String>()
		object.base = "base var"
		object.sub = "sub var"
		
		let json = Mapper().toJSON(object)
		let parsedObject = Mapper<GenericSubclass<String>>().map(json)

		expect(object.base).to(equal(parsedObject?.base))
		expect(object.sub).to(equal(parsedObject?.sub))
	}
	
	func testSubclassWithGenericArrayInSuperclass() {
		let JSONString = "{\"genericItems\":[{\"value\":\"value0\"}, {\"value\":\"value1\"}]}"

		let parsedObject = Mapper<SubclassWithGenericArrayInSuperclass<AnyObject>>().map(JSONString)

		let genericItems = parsedObject?.genericItems
		expect(genericItems).notTo(beNil())
		expect(genericItems?[0].value).to(equal("value0"))
		expect(genericItems?[1].value).to(equal("value1"))
	}
}

infix operator <^> { associativity left }
infix operator <*> { associativity left }

public func <^><T, U>(f: T -> U, a: T?) -> U? {
	return a.map(f)
}

public func <*><T, U>(f: (T -> U)?, a: T?) -> U? {
	return a.apply(f)
}

extension Optional {
	func apply<U>(f: (T -> U)?) -> U? {
		switch (self, f) {
		case let (.Some(x), .Some(fx)): return fx(x)
		default: return .None
		}
	}
}

struct Immutable: Equatable {
	let prop1: String
	let prop2: Int
	let prop3: Bool
}

extension Immutable: Mappable {
	static func create(prop1: String)(prop2: Int)(prop3: Bool) -> Immutable {
		return Immutable(prop1: prop1, prop2: prop2, prop3: prop3)
	}

	init?(_ map: Map) {
		let x = Immutable.create
			<^> map["prop1"].value()
			<*> map["prop2"].value()
			<*> map["prop3"].value()

		if let x = x {
			self = x
		} else {
			return nil
		}
	}

	mutating func mapping(map: Map) {
		switch map.mappingType {
		case .fromJSON:
			if let x = Immutable(map) {
				self = x
			}

		case .toJSON:
			var prop1 = self.prop1
			var prop2 = self.prop2
			var prop3 = self.prop3

			prop1 <- map["prop1"]
			prop2 <- map["prop2"]
			prop3 <- map["prop3"]
		}
	}
}

func ==(lhs: Immutable, rhs: Immutable) -> Bool {
	return lhs.prop1 == rhs.prop1 && lhs.prop2 == rhs.prop2 && lhs.prop3 == rhs.prop3
}

class Response<T: Mappable>: Mappable {
	var result: T?
	
	required init?(_ map: Map) {
		mapping(map)
	}

	func mapping(map: Map) {
		result <- map["result"]
	}
}

class Status: Mappable {
	var status: Int?
	
	required init?(_ map: Map) {
		mapping(map)
	}

	func mapping(map: Map) {
		status <- map["code"]
	}
}

class Plan: Mappable {
	var tasks: [Task]?
	
	required init?(_ map: Map) {
		mapping(map)
	}

	func mapping(map: Map) {
		tasks <- map["tasks"]
	}
}

class Task: Mappable {
	var taskId: Int?
	var percentage: Double?

	init() {}
	
	required init?(_ map: Map) {
		mapping(map)
	}

	func mapping(map: Map) {
		taskId <- map["taskId"]
		percentage <- map["percentage"]
	}
}

class TaskDictionary: Mappable {
	var test: String?
	var tasks: [String : Task]?
	
	required init?(_ map: Map) {
		mapping(map)
	}

	func mapping(map: Map) {
		test <- map["test"]
		tasks <- map["tasks"]
	}
}


// Confirm that struct can conform to `Mappable`
struct Student: Mappable {
	var name: String?
	var UUID: String?
	var major: Int?
	var minor: Int?

	init() {}
	
	init?(_ map: Map) {
		mapping(map)
	}

	mutating func mapping(map: Map) {
		name <- map["name"]
		UUID <- map["UUID"]
		major <- map["major"]
		minor <- map["minor"]
	}
}

class User: Mappable {
    
    var username: String = ""
    var identifier: String?
    var photoCount: Int = 0
    var age: Int?
    var weight: Double?
    var float: Float?
    var drinker: Bool = false
    var smoker: Bool?
    var arr: [AnyObject] = []
    var arrOptional: [AnyObject]?
    var dict: [String : AnyObject] = [:]
    var dictOptional: [String : AnyObject]?
	var dictString: [String : String]?
    var friendDictionary: [String : User]?
    var friend: User?
    var friends: [User]? = []

	init() {}

	required init?(_ map: Map) {
		mapping(map)
	}

	func mapping(map: Map) {
		username         <- map["username"]
		identifier       <- map["identifier"]
		photoCount       <- map["photoCount"]
		age              <- map["age"]
		weight           <- map["weight"]
		float            <- map["float"]
		drinker          <- map["drinker"]
		smoker           <- map["smoker"]
		arr              <- map["arr"]
		arrOptional      <- map["arrOpt"]
		dict             <- map["dict"]
		dictOptional     <- map["dictOpt"]
		friend           <- map["friend"]
		friends          <- map["friends"]
		friendDictionary <- map["friendDictionary"]
		dictString		 <- map["dictString"]
	}
}

class Base: Mappable {
	
	var base: String?

	init() {}
	
	required init?(_ map: Map) {
		mapping(map)
	}

	func mapping(map: Map) {
		base <- map["base"]
	}
}

class Subclass: Base {
	
	var sub: String?

	override init() {
		super.init()
	}
	
	required init?(_ map: Map) {
		super.init(map)
	}

	override func mapping(map: Map) {
		super.mapping(map)
		
		sub <- map["sub"]
	}
}


class GenericSubclass<T>: Base {
	
	var sub: String?

	override init() {
		super.init()
	}

	required init?(_ map: Map) {
		super.init(map)
	}

	override func mapping(map: Map) {
		super.mapping(map)
		
		sub <- map["sub"]
	}
}

class WithGenericArray<T: Mappable>: Mappable {
	var genericItems: [T]?

	required init?(_ map: Map) {
		mapping(map)
	}

	func mapping(map: Map) {
		genericItems <- map["genericItems"]
	}
}

class ConcreteItem: Mappable {
	var value: String?

	required init?(_ map: Map) {
		mapping(map)
	}

	func mapping(map: Map) {
		value <- map["value"]
	}
}

class SubclassWithGenericArrayInSuperclass<Unused>: WithGenericArray<ConcreteItem> {
	required init?(_ map: Map) {
		super.init(map)
	}
}
