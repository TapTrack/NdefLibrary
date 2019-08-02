//
//  NdefRecordTests.swift
//  NdefLibraryTests
//
//  Created by Alice Cai on 2019-07-31.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import XCTest
import NdefLibrary
@testable import NdefLibrary

class NdefRecordTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTextRecordToByteArray() {
        let helloWorldRecordHeader : [UInt8] = [0b11010001, 0x01, 0x11, 0x54];
        let helloWorldRecordPayload : [UInt8] = [0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21];
        
        let helloWorldRecord = Ndef.CreateTextRecord(payload: helloWorldRecordPayload);
        XCTAssertNotNil(helloWorldRecord);
        
        let expectedRawRecord : [UInt8] = helloWorldRecordHeader + helloWorldRecordPayload;
        XCTAssert(helloWorldRecord!.toByteArray(messageBegin: true, messageEnd: true, chunked: false) == expectedRawRecord);
    }
    
    func testTextRecordToByteArrayWithId() {
        let helloWorldRecordHeader : [UInt8] = [0b11011001, 0x01, 0x11, 0x08, 0x54, 0x67, 0x72, 0x65, 0x65, 0x74, 0x69, 0x6e, 0x67];
        let helloWorldRecordPayload : [UInt8] = [0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21];
        
        let languageCode : String = "en"; // 0x65, 0x6E
        let text : String = "hello world!!!";
        let id : String = "greeting"; // 0x67, 0x72, 0x65, 0x65, 0x74, 0x69, 0x6e, 0x67
        
        let helloWorldRecord = Ndef.CreateTextRecord(textEncoding: TextRecord.TextEncodingType.Utf8, languageCode: languageCode, text: text, id: id);
        XCTAssertNotNil(helloWorldRecord);
        
        let expectedRawRecord : [UInt8] = helloWorldRecordHeader + helloWorldRecordPayload;
        XCTAssert(helloWorldRecord!.toByteArray(messageBegin: true, messageEnd: true, chunked: false) == expectedRawRecord);
    }
    
    func testUriRecordToByteArray() {
        let githubUrlRecordHeader : [UInt8] = [0b11010001, 0x01, 0x0C, 0x55];
        let githubUrlRecordPayload : [UInt8] = [0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        
        let githubUrlRecord = Ndef.CreateUriRecord(payload: githubUrlRecordPayload);
        XCTAssertNotNil(githubUrlRecord);
        
        let expectedRawRecord : [UInt8] = githubUrlRecordHeader + githubUrlRecordPayload;
        XCTAssert(githubUrlRecord!.toByteArray(messageBegin: true, messageEnd: true, chunked: false) == expectedRawRecord);
    }
    
    func testUriRecordToByteArrayWithId() {
        let githubUrlRecordHeader : [UInt8] = [0b11011001, 0x01, 0x0C, 0x07, 0x55, 0x6f, 0x63, 0x74, 0x6f, 0x63, 0x61, 0x74];
        let githubUrlRecordPayload : [UInt8] = [0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        
        let url : String = "https://www.github.com/";
        let id : String = "octocat"; // 0x6f, 0x63, 0x74, 0x6f, 0x63, 0x61, 0x74
        
        let githubUrlRecord = Ndef.CreateUriRecord(uri: url, id: id)
        XCTAssertNotNil(githubUrlRecord);
        
        let expectedRawRecord : [UInt8] = githubUrlRecordHeader + githubUrlRecordPayload;
        XCTAssert(githubUrlRecord.toByteArray(messageBegin: true, messageEnd: true, chunked: false) == expectedRawRecord);
    }
    
    func testLongRecordToByteArray() {
        let longPayloadLength : Int = 300;
        let languageCode = "en";
        let longRecordHeader : [UInt8] = [0b11000001, 0x01, 0b0, 0b0, 0b1, 0b00101100, 0x54];
        
        var longRecordPayload : [UInt8] = [0b10, 0x65, 0x6E];
        var longRecordText : String = "";
        for _ in 4...longPayloadLength { // first three bytes reserved for status byte and language code
            longRecordPayload.append(0x21);
            longRecordText += "!";
        }
        let expectedRawRecord : [UInt8] = longRecordHeader + longRecordPayload;
        
        let longRecord1 = Ndef.CreateTextRecord(payload: longRecordPayload);
        XCTAssertNotNil(longRecord1);
        XCTAssert(longRecord1!.toByteArray(messageBegin: true, messageEnd: true, chunked: false) == expectedRawRecord);
        
        let longRecord2 = Ndef.CreateTextRecord(textEncoding: TextRecord.TextEncodingType.Utf8, languageCode: languageCode, text: longRecordText);
        XCTAssertNotNil(longRecord2);
        XCTAssert(longRecord2!.toByteArray(messageBegin: true, messageEnd: true, chunked: false) == expectedRawRecord);
    }
    
}
