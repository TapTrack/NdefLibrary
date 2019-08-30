//
//  GenericRecordTests.swift
//  NdefLibraryTests
//
//  Created by Alice Cai on 2019-07-30.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import XCTest
import NdefLibrary
@testable import NdefLibrary

class GenericRecordTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConstructor() {
        let typeNameFormat = TypeNameFormat.mimeMedia;
        let type : [UInt8] = [];
        let payload : [UInt8] = [0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65];
        
        let genericRecord = Ndef.makeGenericRecord(tnf: typeNameFormat, type: type, payload: payload);
        XCTAssertNotNil(genericRecord);
        
        XCTAssert(genericRecord!.tnf == typeNameFormat.rawValue);
        XCTAssert(genericRecord!.type == type);
        XCTAssert(genericRecord!.payload == payload);
        XCTAssertNil(genericRecord!.id);
    }
    
    func testConstructorId() {
        let typeNameFormat = TypeNameFormat.mimeMedia;
        let type : [UInt8] = [];
        let payload : [UInt8] = [0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65];
        let id : [UInt8] = [0x61, 0x62, 0x63, 0x64];
        
        XCTAssertNotNil(Ndef.makeGenericRecord(tnf: typeNameFormat, type: type, payload: payload, id: id));
        let genericRecord = Ndef.makeGenericRecord(tnf: typeNameFormat, type: type, payload: payload, id: id);
        
        XCTAssert(genericRecord!.tnf == typeNameFormat.rawValue);
        XCTAssert(genericRecord!.type == type);
        XCTAssert(genericRecord!.payload == payload);
        XCTAssertNotNil(genericRecord!.id);
        XCTAssert(genericRecord!.id! == id);
    }
    
    func testDuplicateRecord() {
        let genericRecord = Ndef.makeGenericRecord(tnf: TypeNameFormat.mimeMedia, type: [], payload: []);
        XCTAssertNotNil(genericRecord);
        XCTAssertNotNil(Ndef.makeGenericRecord(other: genericRecord!));
    }
    
    func testIsRecordType() {
        let genericRecord = Ndef.makeGenericRecord(tnf: TypeNameFormat.mimeMedia, type: [], payload: []);
        XCTAssertTrue(GenericRecord.isRecordType(record: genericRecord));
        
        let textRecord = Ndef.makeTextRecord(payload: [0x02, 0x65, 0x6E]);
        XCTAssertFalse(GenericRecord.isRecordType(record: textRecord!));
        
        XCTAssertFalse(GenericRecord.isRecordType(record: Ndef.makeUriRecord()));
    }
    
}
