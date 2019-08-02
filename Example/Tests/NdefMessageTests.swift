//
//  NdefMessageTests.swift
//  NdefLibraryTests
//
//  Created by Alice Cai on 2019-07-30.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import XCTest
import NdefLibrary
@testable import NdefLibrary

class NdefMessageTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testSingleRecordParsing() {
        // message with single uri record
        let github : [UInt8] = [0xD1, 0x01, 0x0C, 0x55, 0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F]; // github (uri)
        XCTAssertNotNil(Ndef.CreateNdefMessage(rawByteArray: github));
        let githubMsg = Ndef.CreateNdefMessage(rawByteArray: github);
        
        XCTAssert(githubMsg!.numRecords == 1);
        XCTAssert(githubMsg!.records[0] is UriRecord);
        if let uriRecord = githubMsg!.records[0] as? UriRecord {
            XCTAssert(uriRecord.uri == "https://www.github.com/");
        }
        
        // message with single text record
        let helloWorldTextRecord : [UInt8] = [0xD1, 0x01, 0x11, 0x54, 0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21];
        XCTAssertNoThrow(Ndef.CreateNdefMessage(rawByteArray: helloWorldTextRecord));
        let helloWorldMsg = Ndef.CreateNdefMessage(rawByteArray: helloWorldTextRecord);
        
        XCTAssert(helloWorldMsg!.numRecords == 1);
        if let textRecord = helloWorldMsg!.records[0] as? TextRecord {
            XCTAssert(textRecord.text == "hello world!!!");
        }
    }
    
    func testUriRecordParsing() {
        // raw byte arrays for URI records
        let githubRawUriRecord : [UInt8] = [0x91, 0x01, 0x0C, 0x55, 0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        let wristcoinRawUriRecord : [UInt8] = [0x11, 0x01, 0x10, 0x55, 0x01, 0x6D, 0x79, 0x77, 0x72, 0x69, 0x73, 0x74, 0x63, 0x6F, 0x69, 0x6E, 0x2E, 0x63, 0x6F, 0x6D];
        let instagramRawUriRecord : [UInt8] = [0x51, 0x01, 0x0F, 0x55, 0x02, 0x69, 0x6e, 0x73, 0x74, 0x61, 0x67, 0x72, 0x61, 0x6d, 0x2e, 0x63, 0x6f, 0x6d, 0x2f];
        
        let githubWristCoinInstagramRaw : [UInt8] = githubRawUriRecord + wristcoinRawUriRecord + instagramRawUriRecord;
        XCTAssertNotNil(Ndef.CreateNdefMessage(rawByteArray: githubWristCoinInstagramRaw));
        let githubWristCoinInstagramMsg = Ndef.CreateNdefMessage(rawByteArray: githubWristCoinInstagramRaw);
        
        XCTAssert(githubWristCoinInstagramMsg!.numRecords == 3);
        XCTAssert(githubWristCoinInstagramMsg!.records[0] is UriRecord);
        if let uriRecord = githubWristCoinInstagramMsg!.records[0] as? UriRecord {
            XCTAssert(uriRecord.uri == "https://www.github.com/");
        }
        XCTAssert(githubWristCoinInstagramMsg!.records[1] is UriRecord);
        if let uriRecord = githubWristCoinInstagramMsg!.records[1] as? UriRecord {
            XCTAssert(uriRecord.uri == "http://www.mywristcoin.com");
        }
        XCTAssert(githubWristCoinInstagramMsg!.records[2] is UriRecord);
        if let uriRecord = githubWristCoinInstagramMsg!.records[2] as? UriRecord {
            XCTAssert(uriRecord.uri == "https://www.instagram.com/");
        }
    }
    
    func testTextRecordParsing() {
        let helloWorldRawTextRecord : [UInt8] = [0x91, 0x01, 0x11, 0x54, 0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21]; // hello world!!!
        let salutRawTextRecord : [UInt8] = [0x51, 0x01, 0x11, 0x54, 0x02, 0x66, 0x72, 0x73, 0x61, 0x6C, 0x75, 0x74, 0x21, 0x20, 0xC3, 0xA7, 0x61, 0x20, 0x76, 0x61, 0x3F]; // salut! ça va?
        
        let helloSalutRawMsg : [UInt8] = helloWorldRawTextRecord + salutRawTextRecord;
        XCTAssertNotNil(Ndef.CreateNdefMessage(rawByteArray: helloSalutRawMsg));
        let helloSalutMsg = Ndef.CreateNdefMessage(rawByteArray: helloSalutRawMsg);
        
        XCTAssert(helloSalutMsg!.numRecords == 2);
        XCTAssert(helloSalutMsg!.records[0] is TextRecord);
        if let textRecord = helloSalutMsg!.records[0] as? TextRecord {
            XCTAssert(textRecord.text == "hello world!!!");
        }
        XCTAssert(helloSalutMsg!.records[1] is TextRecord);
        if let textRecord = helloSalutMsg!.records[1] as? TextRecord {
            XCTAssert(textRecord.text == "salut! ça va?");
        }
    }
    
    func testGenericRecordParsing() {
        let rawGenericRecord1 : [UInt8] = [0x92, 0x01, 0x01, 0x02, 0x11];
        let rawGenericRecord2 : [UInt8] = [0x55, 0x01, 0x01, 0x02, 0x12];
        
        let rawGenericMessage : [UInt8] = rawGenericRecord1 + rawGenericRecord2;
        XCTAssertNotNil(Ndef.CreateNdefMessage(rawByteArray: rawGenericMessage));
        let genericMessage = Ndef.CreateNdefMessage(rawByteArray: rawGenericMessage);
        
        XCTAssert(genericMessage!.numRecords == 2);
        XCTAssert(genericMessage!.records[0].payload == [0x11]);
        XCTAssert(genericMessage!.records[1].payload == [0x12]);
    }
    
    func testMultiTypeRecordParsing() {
        let helloWorldRawTextRecord : [UInt8] = [0x91, 0x01, 0x11, 0x54, 0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21]; // hello world!!!
        let rawGenericRecord1 : [UInt8] = [0x12, 0x01, 0x01, 0x02, 0x11];
        let githubRawUriRecord : [UInt8] = [0x11, 0x01, 0x0C, 0x55, 0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        let salutRawTextRecord : [UInt8] = [0x11, 0x01, 0x11, 0x54, 0x02, 0x66, 0x72, 0x73, 0x61, 0x6C, 0x75, 0x74, 0x21, 0x20, 0xC3, 0xA7, 0x61, 0x20, 0x76, 0x61, 0x3F]; // salut! ça va?
        let wristcoinRawUriRecord : [UInt8] = [0x51, 0x01, 0x10, 0x55, 0x01, 0x6D, 0x79, 0x77, 0x72, 0x69, 0x73, 0x74, 0x63, 0x6F, 0x69, 0x6E, 0x2E, 0x63, 0x6F, 0x6D];
        
        let rawMultiTypeMessage : [UInt8] = helloWorldRawTextRecord + rawGenericRecord1 + githubRawUriRecord + salutRawTextRecord + wristcoinRawUriRecord;
        XCTAssertNotNil(Ndef.CreateNdefMessage(rawByteArray: rawMultiTypeMessage));
        let multiTypeMessage = Ndef.CreateNdefMessage(rawByteArray: rawMultiTypeMessage);
        
        XCTAssert(multiTypeMessage!.numRecords == 5);
        XCTAssert(multiTypeMessage!.records[0] is TextRecord);
        if let textRecord = multiTypeMessage!.records[0] as? TextRecord {
            XCTAssert(textRecord.text == "hello world!!!");
        }
        XCTAssert(multiTypeMessage!.records[1] is GenericRecord);
        if let genericRecord = multiTypeMessage!.records[1] as? GenericRecord {
            XCTAssert(genericRecord.payload == [0x11]);
        }
        XCTAssert(multiTypeMessage!.records[2] is UriRecord);
        if let uriRecord = multiTypeMessage!.records[2] as? UriRecord {
            XCTAssert(uriRecord.uri == "https://www.github.com/");
        }
        XCTAssert(multiTypeMessage!.records[3] is TextRecord);
        if let textRecord = multiTypeMessage!.records[3] as? TextRecord {
            XCTAssert(textRecord.text == "salut! ça va?");
        }
        XCTAssert(multiTypeMessage!.records[4] is UriRecord);
        if let uriRecord = multiTypeMessage!.records[4] as? UriRecord {
            XCTAssert(uriRecord.uri == "http://www.mywristcoin.com");
        }
    }
    
    func testLongRecordParsing() {
        let longTextPayloadLength : Int = 300;
        var longTextRecordRaw : [UInt8] = [0b11000001, 0x01, 0b0, 0b0, 0b1, 0b00101100, 0x54, 0b10, 0x65, 0x6E];
        var longTextRecordText : String = "";
        for _ in 4...longTextPayloadLength { // first three bytes reserved for status byte and language code
            longTextRecordRaw.append(0x21);
            longTextRecordText += "!";
        }
        
        XCTAssertNotNil(Ndef.CreateNdefMessage(rawByteArray: longTextRecordRaw));
        let longTextRecordMsg = Ndef.CreateNdefMessage(rawByteArray: longTextRecordRaw);
        
        XCTAssert(longTextRecordMsg!.numRecords == 1);
        XCTAssert(longTextRecordMsg!.records[0] is TextRecord);
        if let textRecord = longTextRecordMsg!.records[0] as? TextRecord {
            XCTAssert(textRecord.text == longTextRecordText);
        }
    }
    
    func testMultiLengthRecordParsing() {
        let githubRawUriRecordLong : [UInt8] = [0b10000001, 0x01, 0x00, 0x00, 0x00, 0x0C, 0x55, 0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F]; // "https://www.github.com/"
        let helloWorldRawTextRecordShort : [UInt8] = [0b00010001, 0x01, 0x11, 0x54, 0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21]; // hello world!!!
        let salutRawTextRecordLong : [UInt8] = [0b01000001, 0x01, 0x00, 0x00, 0x00, 0x11, 0x54, 0x02, 0x66, 0x72, 0x73, 0x61, 0x6C, 0x75, 0x74, 0x21, 0x20, 0xC3, 0xA7, 0x61, 0x20, 0x76, 0x61, 0x3F]; // salut! ça va?
        
        let rawMultiLengthMsg : [UInt8] = githubRawUriRecordLong + helloWorldRawTextRecordShort + salutRawTextRecordLong;
        XCTAssertNotNil(Ndef.CreateNdefMessage(rawByteArray: rawMultiLengthMsg));
        let multiLengthMsg = Ndef.CreateNdefMessage(rawByteArray: rawMultiLengthMsg);
        
        XCTAssert(multiLengthMsg!.numRecords == 3);
        XCTAssert(multiLengthMsg!.records[0] is UriRecord);
        if let uriRecord = multiLengthMsg!.records[0] as? UriRecord {
            XCTAssert(uriRecord.uri == "https://www.github.com/");
        }
        XCTAssert(multiLengthMsg!.records[1] is TextRecord);
        if let textRecord = multiLengthMsg!.records[1] as? TextRecord {
            XCTAssert(textRecord.text == "hello world!!!");
        }
        XCTAssert(multiLengthMsg!.records[2] is TextRecord);
        if let textRecord = multiLengthMsg!.records[2] as? TextRecord {
            XCTAssert(textRecord.text == "salut! ça va?");
        }
    }
    
    func testParsingErrors() {
        // NdefMessage.MessageParsingError.rawByteArrayTooShort
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: []));
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0x00]));
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0x00, 0x00]));
        
        // NdefMessage.MessageParsingError.multipleMessageBeginFlags
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0b10010001, 0x00, 0x00, 0b10010001]));
        
        // NdefMessage.MessageParsingError.messageBeginFlagMissing
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0b00010001, 0x00, 0x00]));
        
        // note: not testing for this error because it can only occur when chunked records are supported
        // NdefMessage.MessageParsingError.multipleMessageEndFlags
        // XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0b10010001, 0x00, 0x00, 0b01110001, 0x00, 0x00, 0b01110001]));
        
        // NdefMessage.MessageParsingError.chunkedRecordsNotSupported
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0b10110001, 0x00, 0x00]));
        
        // NdefMessage.MessageParsingError.typeLengthMissing
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0b10010001, 0x00, 0x00, 0b00010001]));
        
        // NdefMessage.MessageParsingError.payloadLengthMissing
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0b10010001, 0x00, 0x00, 0b00010001, 0x00]));
        
        // NdefMessage.MessageParsingError.idLengthMissing
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0b10011001, 0x00, 0x00]));
        
        // NdefMessage.MessageParsingError.typeFieldMissing
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0b10010001, 0x01, 0x00]));
        
        // NdefMessage.MessageParsingError.idFieldMissing
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0b10011001, 0x00, 0x00, 0x01]));
        
        // NdefMessage.MessageParsingError.payloadFieldMissing
        XCTAssertNil(Ndef.CreateNdefMessage(rawByteArray: [0b10010001, 0x00, 0x01]));
    }
    
    func testEmptyMessageToByteArray() {
        let emptyMessage = Ndef.CreateNdefMessage();
        XCTAssertNotNil(emptyMessage);
        XCTAssert(emptyMessage.toByteArray() == []);
    }
    
    func testMultiTypeMessageToByteArray() {
        // Construct UriRecord.
        let githubUrlRecordHeader : [UInt8] = [0b10011001, 0x01, 0x0C, 0x07, 0x55, 0x6f, 0x63, 0x74, 0x6f, 0x63, 0x61, 0x74];
        let githubUrlRecordPayload : [UInt8] = [0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        let rawGithubUrlRecord : [UInt8] = githubUrlRecordHeader + githubUrlRecordPayload;
        let githubUrlRecord = Ndef.CreateUriRecord(uri: "https://www.github.com/", id: "octocat");
        XCTAssertNotNil(githubUrlRecord);
        
        // Construct GenericRecord.
        let genericRecordHeader : [UInt8] = [0b00010010, 0x01, 0x01, 0x02];
        let genericRecordPayload : [UInt8] = [0x11];
        let rawGenericRecord : [UInt8] = genericRecordHeader + genericRecordPayload;
        let genericRecord = Ndef.CreateGenericRecord(tnf: Ndef.TypeNameFormat.mimeMedia, type: [0x02], payload: [0x11]);
        XCTAssertNotNil(genericRecord);
        
        // Construct TextRecord.
        let helloWorldRecordHeader : [UInt8] = [0b01010001, 0x01, 0x11, 0x54];
        let helloWorldRecordPayload : [UInt8] = [0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21];
        let rawHelloWorldRecord : [UInt8] = helloWorldRecordHeader + helloWorldRecordPayload;
        let helloWorldRecord = Ndef.CreateTextRecord(payload: helloWorldRecordPayload);
        XCTAssertNotNil(helloWorldRecord);
        
        // Construct NdefMessage and check return value of toByteArray().
        let rawMessage : [UInt8] = rawGithubUrlRecord + rawGenericRecord + rawHelloWorldRecord;
        let message = Ndef.CreateNdefMessage(records: [githubUrlRecord, genericRecord!, helloWorldRecord!]);
        XCTAssert(message.toByteArray() == rawMessage);
    }
    
    func testMultiLengthMessageToByteArray() {
        // Construct TextRecord (long).
        let longTextRecordPayloadLength : Int = 300;
        let longTextRecordHeader : [UInt8] = [0b10000001, 0x01, 0b0, 0b0, 0b1, 0b00101100, 0x54];
        
        var longTextRecordPayload : [UInt8] = [0b10, 0x65, 0x6E];
        var longTextRecordText : String = "";
        for _ in 4...longTextRecordPayloadLength { // first three bytes reserved for status byte and language code
            longTextRecordPayload.append(0x21);
            longTextRecordText += "!";
        }
        let rawLongTextRecord : [UInt8] = longTextRecordHeader + longTextRecordPayload;
        
        let longTextRecord = Ndef.CreateTextRecord(payload: longTextRecordPayload);
        XCTAssertNotNil(longTextRecord);
        
        // Construct UriRecord (short).
        let githubUrlRecordHeader : [UInt8] = [0b01011001, 0x01, 0x0C, 0x07, 0x55, 0x6f, 0x63, 0x74, 0x6f, 0x63, 0x61, 0x74];
        let githubUrlRecordPayload : [UInt8] = [0x02, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D, 0x2F];
        let rawGithubUrlRecord : [UInt8] = githubUrlRecordHeader + githubUrlRecordPayload;
        let githubUrlRecord = Ndef.CreateUriRecord(uri: "https://www.github.com/", id: "octocat");
        XCTAssertNotNil(githubUrlRecord);
        
        // Construct NdefMessage and check return value of toByteArray().
        let rawMessage : [UInt8] = rawLongTextRecord + rawGithubUrlRecord;
        let message = Ndef.CreateNdefMessage(records: [longTextRecord!, githubUrlRecord]);
        XCTAssert(message.toByteArray() == rawMessage);
    }
    
    func testAppendRecord() {
        let textRecord = Ndef.CreateTextRecord(textEncoding: TextRecord.TextEncodingType.Utf8, languageCode: "en", text: "");
        XCTAssertNotNil(textRecord);
        let uriRecord = Ndef.CreateUriRecord(uri: "");
        let genericRecord = Ndef.CreateGenericRecord(tnf: Ndef.TypeNameFormat.unknown, type: [0x02], payload: []);
        XCTAssertNotNil(genericRecord);
        
        let message = Ndef.CreateNdefMessage();
        XCTAssert(message.numRecords == 0);
        XCTAssert(message.records.count == 0);
        
        message.appendRecord(record: textRecord!);
        XCTAssert(message.numRecords == 1);
        XCTAssert(message.records[0] is TextRecord);
        
        message.appendRecord(record: uriRecord);
        XCTAssert(message.numRecords == 2);
        XCTAssert(message.records[1] is UriRecord);
        
        message.appendRecord(record: genericRecord!);
        XCTAssert(message.numRecords == 3);
        XCTAssert(message.records[2] is GenericRecord);
    }
    
    func testInsertRecord() {
        let textRecord = Ndef.CreateTextRecord(textEncoding: TextRecord.TextEncodingType.Utf8, languageCode: "en", text: "");
        XCTAssertNotNil(textRecord);
        let uriRecord = Ndef.CreateUriRecord(uri: "");
        let genericRecord = Ndef.CreateGenericRecord(tnf: Ndef.TypeNameFormat.unknown, type: [0x02], payload: []);
        XCTAssertNotNil(genericRecord);
        
        let message = Ndef.CreateNdefMessage(records: [textRecord!]);
        XCTAssert(message.numRecords == 1);
        XCTAssert(message.records[0] is TextRecord);
        
        message.insertRecord(record: uriRecord, at: 0);
        XCTAssert(message.numRecords == 2);
        XCTAssert(message.records[0] is UriRecord);
        XCTAssert(message.records[1] is TextRecord);
        
        message.insertRecord(record: genericRecord!, at: 1);
        XCTAssert(message.numRecords == 3);
        XCTAssert(message.records[0] is UriRecord);
        XCTAssert(message.records[1] is GenericRecord);
        XCTAssert(message.records[2] is TextRecord);
    }
    
    func testRemoveRecord() {
        let textRecord = Ndef.CreateTextRecord(textEncoding: TextRecord.TextEncodingType.Utf8, languageCode: "en", text: "");
        XCTAssertNotNil(textRecord);
        let uriRecord = Ndef.CreateUriRecord(uri: "");
        let genericRecord = Ndef.CreateGenericRecord(tnf: Ndef.TypeNameFormat.unknown, type: [0x02], payload: []);
        XCTAssertNotNil(genericRecord);
        
        let message = Ndef.CreateNdefMessage(records: [textRecord!, uriRecord, genericRecord!]);
        XCTAssert(message.numRecords == 3);
        XCTAssert(message.records[0] is TextRecord);
        XCTAssert(message.records[1] is UriRecord);
        XCTAssert(message.records[2] is GenericRecord);
        
        message.removeRecord(at: 1);
        XCTAssert(message.numRecords == 2);
        XCTAssert(message.records[0] is TextRecord);
        XCTAssert(message.records[1] is GenericRecord);
        
        message.removeRecord(at: 0);
        XCTAssert(message.numRecords == 1);
        XCTAssert(message.records[0] is GenericRecord);
        
        message.removeRecord(at: 0);
        XCTAssert(message.numRecords == 0);
        XCTAssert(message.records.count == 0);
        
        // silently fails
        XCTAssertNoThrow(message.removeRecord(at: 0));
    }
    
}
