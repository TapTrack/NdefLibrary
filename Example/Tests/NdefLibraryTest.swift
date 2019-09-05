////
////  NdefLibraryTest.swift
////  NdefLibrary_Tests
////
////  Created by Alice Cai on 2019-08-02.
////  Copyright © 2019 CocoaPods. All rights reserved.
////
//
//import XCTest
//import NdefLibrary
//@testable import NdefLibrary
//
//class NdefLibraryTest: XCTestCase {
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        XCTAssert(true, "Pass")
//    }
//
//    func testReadme() {
//        // Empty NDEF record for example purposes.
//        let rawNdefMessage : [UInt8] = [0xD0, 0x00, 0x00]
//
//        // Construct an NdefMessage from a raw byte array. If the raw byte array does
//        // not represent a valid, complete NDEF message, this method will return nil.
//        let message = Ndef.makeNdefMessage(rawByteArray: rawNdefMessage)
//
//        // Unwrap the message and get the array of records.
//        var records : [NdefRecord] = []
//        if let unwrappedMsg = message {
//            records = unwrappedMsg.records
//        }
//
//        for record in records {
//            NSLog("Type Name Format: \(record.tnf)")
//            NSLog("Type: \(record.type)")
//            NSLog("Payload: \(record.payload)")
//        }
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}
