//
//  UriRecordTests.swift
//  NdefLibraryTests
//
//  Created by Alice Cai on 2019-07-30.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import XCTest
import NdefLibrary
@testable import NdefLibrary

class UriRecordTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEmptyConstructor() {
        XCTAssertNoThrow(Ndef.CreateUriRecord());
        let emptyUriRecord = Ndef.CreateUriRecord();
        
        XCTAssert(emptyUriRecord.tnf == Ndef.TypeNameFormat.wellKnown.rawValue);
        XCTAssert(emptyUriRecord.type == UriRecord.RecordType);
        XCTAssert(emptyUriRecord.payload == []);
        XCTAssert(emptyUriRecord.rawUri == []);
        XCTAssert(emptyUriRecord.uri == "");
    }
    
    func testPayloadConstructor() {
        let githubUrlPayload : [UInt8] = [0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        
        let githubRecord = Ndef.CreateUriRecord(payload: githubUrlPayload);
        XCTAssertNotNil(githubRecord);
        
        XCTAssertNil(githubRecord!.id);
        XCTAssert(githubRecord!.tnf == Ndef.TypeNameFormat.wellKnown.rawValue);
        XCTAssert(githubRecord!.type == UriRecord.RecordType);
        XCTAssert(githubRecord!.payload == githubUrlPayload);
        XCTAssert(githubRecord!.rawUri == [0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F]);
        XCTAssert(githubRecord!.uri == "https://www.github.com/");
    }
    
    func testPayloadConstructorWithId() {
        let githubUrlPayload : [UInt8] = [0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        let githubId : [UInt8] = [0x67, 0x69, 0x74, 0x68, 0x75, 0x62];
        
        let githubRecord = Ndef.CreateUriRecord(payload: githubUrlPayload, id: githubId);
        XCTAssertNotNil(githubRecord);
        
        XCTAssertNotNil(githubRecord!.id);
        XCTAssert(githubRecord!.id! == githubId);
        XCTAssert(githubRecord!.tnf == Ndef.TypeNameFormat.wellKnown.rawValue);
        XCTAssert(githubRecord!.type == UriRecord.RecordType);
        XCTAssert(githubRecord!.payload == githubUrlPayload);
        XCTAssert(githubRecord!.rawUri == [0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F]);
        XCTAssert(githubRecord!.uri == "https://www.github.com/");
    }
    
    func testUriStringConstructor() {
        let githubUrlPayload : [UInt8] = [0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        let githubUrl = "https://www.github.com/";
        
        let githubRecord = Ndef.CreateUriRecord(uri: githubUrl);
        XCTAssertNotNil(githubRecord);
        
        XCTAssertNil(githubRecord.id);
        XCTAssert(githubRecord.tnf == Ndef.TypeNameFormat.wellKnown.rawValue);
        XCTAssert(githubRecord.type == UriRecord.RecordType);
        XCTAssert(githubRecord.payload == githubUrlPayload);
        XCTAssert(githubRecord.rawUri == [0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F]);
        XCTAssert(githubRecord.uri == "https://www.github.com/");
    }
    
    func testUriStringConstructorWithId() {
        let githubUrlPayload : [UInt8] = [0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        let githubUrl = "https://www.github.com/";
        let githubId = "github";
        
        let githubRecord = Ndef.CreateUriRecord(uri: githubUrl, id: githubId);
        XCTAssertNotNil(githubRecord);
        
        XCTAssertNotNil(githubRecord.id);
        XCTAssert(githubRecord.id! == Array(githubId.utf8));
        XCTAssert(githubRecord.tnf == Ndef.TypeNameFormat.wellKnown.rawValue);
        XCTAssert(githubRecord.type == UriRecord.RecordType);
        XCTAssert(githubRecord.payload == githubUrlPayload);
        XCTAssert(githubRecord.rawUri == [0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F]);
        XCTAssert(githubRecord.uri == githubUrl);
    }
    
    func testDuplicateRecord() {
        let githubUrlPayload : [UInt8] = [0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        let githubUrl = "https://www.github.com/";
        
        XCTAssertNotNil(Ndef.CreateUriRecord(other: UriRecord()));
        
        let uriRecord = Ndef.CreateUriRecord(payload: githubUrlPayload);
        XCTAssertNotNil(uriRecord);
        let duplicate = Ndef.CreateUriRecord(other: uriRecord!);
        XCTAssertNotNil(duplicate);
        XCTAssert(duplicate.payload == githubUrlPayload);
        XCTAssert(duplicate.uri == githubUrl);
    }
    
    func testIsRecordType() {
        let uriRecord = Ndef.CreateUriRecord(payload: []);
        XCTAssertTrue(UriRecord.isRecordType(record: uriRecord));
        
        let textRecord = Ndef.CreateTextRecord(textEncoding: TextRecord.TextEncodingType.Utf8, languageCode: "en", text: "");
        XCTAssertFalse(UriRecord.isRecordType(record: textRecord!));
        
        let genericRecord = Ndef.CreateGenericRecord(tnf: Ndef.TypeNameFormat.mimeMedia, type: [], payload: []);
        XCTAssertFalse(UriRecord.isRecordType(record: genericRecord));
    }
    
    func testErrors() {
        
    }
    
    func testMutators() {
        let id = "github";
        let payload : [UInt8] = [0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        let uri = "https://www.github.com/";
        
        XCTAssertNotNil(Ndef.CreateUriRecord(uri: uri, id: id));
        let uriRecord = Ndef.CreateUriRecord(uri: uri, id: id);
        XCTAssert(uriRecord.id! == Array(id.utf8));
        XCTAssert(uriRecord.payload == payload);
        XCTAssert(uriRecord.uri == uri);
        
        // Mutate id.
        let newId = "wristcoin";
        uriRecord.id = Array(newId.utf8);
        XCTAssert(uriRecord.id! == Array(newId.utf8));
        XCTAssert(uriRecord.payload == payload);
        XCTAssert(uriRecord.uri == uri);
        
        // Mutate payload.
        let wristcoinUriString = "http://www.mywristcoin.com/";
        let wristcoinUriBytes : [UInt8] = [0x01, 0x6D, 0x79, 0x77, 0x72, 0x69, 0x73, 0x74, 0x63, 0x6F, 0x69, 0x6E, 0x2E, 0x63, 0x6F, 0x6D, 0x2f];
        uriRecord.payload = wristcoinUriBytes;
        XCTAssert(uriRecord.id! == Array(newId.utf8));
        XCTAssert(uriRecord.payload == wristcoinUriBytes);
        XCTAssert(uriRecord.uri == wristcoinUriString);
        
        // Mutate uri string.
        let instagramUriString = "https://www.instagram.com/";
        let instagramUriBytes : [UInt8] = [0x02, 0x69, 0x6e, 0x73, 0x74, 0x61, 0x67, 0x72, 0x61, 0x6d, 0x2e, 0x63, 0x6f, 0x6d, 0x2f];
        uriRecord.uri = instagramUriString;
        XCTAssert(uriRecord.id! == Array(newId.utf8));
        XCTAssert(uriRecord.payload == instagramUriBytes);
        XCTAssert(uriRecord.uri == instagramUriString);
    }
    
}
