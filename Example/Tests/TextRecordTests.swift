//
//  TextRecordTests.swift
//  NdefLibraryTests
//
//  Created by Alice Cai on 2019-07-30.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import XCTest
import NdefLibrary
@testable import NdefLibrary

class TextRecordTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPayloadConstructor() {
        // Construct TextRecord by specifying payload.
        let helloWorldPayload : [UInt8] = [0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21];
        
        XCTAssertNotNil(Ndef.makeTextRecord(payload: helloWorldPayload));
        let helloWorld = Ndef.makeTextRecord(payload: helloWorldPayload);
        
        XCTAssertNil(helloWorld!.id);
        XCTAssert(helloWorld!.tnf == TypeNameFormat.wellKnown.rawValue);
        XCTAssert(helloWorld!.type == TextRecord.recordType);
        XCTAssert(helloWorld!.payload == helloWorldPayload);
        XCTAssert(helloWorld!.textEncoding == TextEncodingType.Utf8);
        XCTAssert(helloWorld!.languageCode == "en");
        XCTAssert(helloWorld!.text == "hello world!!!");
        XCTAssert(helloWorld!.textLength == "hello world!!!".count);
    }
    
    
    func testPayloadConstructorWithId() {
        let helloWorldPayload : [UInt8] = [0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21];
        let helloId : [UInt8] = [0x68, 0x65, 0x6C, 0x6C, 0x6F];
        
        XCTAssertNotNil(Ndef.makeTextRecord(payload: helloWorldPayload, id: helloId));
        let helloWorld = Ndef.makeTextRecord(payload: helloWorldPayload, id: helloId);
        
        XCTAssertNotNil(helloWorld!.id);
        XCTAssert(helloWorld!.id! == helloId);
        XCTAssert(helloWorld!.tnf == TypeNameFormat.wellKnown.rawValue);
        XCTAssert(helloWorld!.type == TextRecord.recordType);
        XCTAssert(helloWorld!.payload == helloWorldPayload);
        XCTAssert(helloWorld!.textEncoding == TextEncodingType.Utf8);
        XCTAssert(helloWorld!.languageCode == "en");
        XCTAssert(helloWorld!.text == "hello world!!!");
        XCTAssert(helloWorld!.textLength == "hello world!!!".count);
    }
    
    
    func testAsciiText() {
        let helloWorldPayload : [UInt8] = [0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21];
        let textEncoding = TextEncodingType.Utf8;
        let languageCode : String = "en";
        let text : String = "hello world!!!";
        
        XCTAssertNotNil(Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text));
        let helloWorld = Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text);
        
        XCTAssertNil(helloWorld!.id);
        XCTAssert(helloWorld!.tnf == TypeNameFormat.wellKnown.rawValue);
        XCTAssert(helloWorld!.type == TextRecord.recordType);
        XCTAssert(helloWorld!.payload == helloWorldPayload);
        XCTAssert(helloWorld!.textEncoding == TextEncodingType.Utf8);
        XCTAssert(helloWorld!.languageCode == languageCode);
        XCTAssert(helloWorld!.text == text);
        XCTAssert(helloWorld!.textLength == text.count);
    }
    
    
    func testAsciiTextWithId () {
        let helloWorldPayload : [UInt8] = [0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21];
        let textEncoding = TextEncodingType.Utf8;
        let languageCode : String = "en";
        let text : String = "hello world!!!";
        let idString : String = "greeting";
        let idBinary : [UInt8] = Array(idString.utf8);
        
        XCTAssertNotNil(Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text, id: idString));
        let helloWorld = Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text, id: idString);
        
        XCTAssertNotNil(helloWorld!.id);
        XCTAssert(helloWorld!.id! == idBinary);
        XCTAssert(helloWorld!.tnf == TypeNameFormat.wellKnown.rawValue);
        XCTAssert(helloWorld!.type == TextRecord.recordType);
        XCTAssert(helloWorld!.payload == helloWorldPayload);
        XCTAssert(helloWorld!.textEncoding == TextEncodingType.Utf8);
        XCTAssert(helloWorld!.languageCode == languageCode);
        XCTAssert(helloWorld!.text == text);
        XCTAssert(helloWorld!.textLength == text.count);
    }
    
    
    func testNumbers() {
        let textEncoding = TextEncodingType.Utf8;
        let languageCode : String = "en";
        let text : String = "123test 1337c0d3";
        let expectedPayload : [UInt8] = [0x02, 0x65, 0x6E, 0x31, 0x32, 0x33, 0x74, 0x65, 0x73, 0x74, 0x20, 0x31, 0x33, 0x33, 0x37, 0x63, 0x30, 0x64, 0x33];
        
        XCTAssertNotNil(Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text));
        let numbers = Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text);
        
        XCTAssertNil(numbers!.id);
        XCTAssert(numbers!.tnf == TypeNameFormat.wellKnown.rawValue);
        XCTAssert(numbers!.type == TextRecord.recordType);
        XCTAssert(numbers!.payload == expectedPayload);
        XCTAssert(numbers!.textEncoding == TextEncodingType.Utf8);
        XCTAssert(numbers!.languageCode == languageCode);
        XCTAssert(numbers!.text == text);
        XCTAssert(numbers!.textLength == text.count);
    }
    
    
    func testUnicodeChinese() {
        let text: String = "加油!"; // jia you!
        let textEncoding = TextEncodingType.Utf16;
        let languageCode : String = "zh-Hans";
        
        XCTAssertNotNil(Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text));
        let chineseText = Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text);
        
        XCTAssert(chineseText!.id == nil);
        XCTAssert(chineseText!.tnf == TypeNameFormat.wellKnown.rawValue);
        XCTAssert(chineseText!.type == TextRecord.recordType);
        XCTAssert(chineseText!.textEncoding == TextEncodingType.Utf16);
        XCTAssert(chineseText!.languageCode == languageCode);
        XCTAssert(chineseText!.text == text);
    }
    
    
    func testUnicodeEmoji() {
        let text: String = "🤠👀💅🤩🐸🍵";
        let textEncoding = TextEncodingType.Utf16;
        let languageCode : String = "fr";
        
        XCTAssertNotNil(Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text));
        let emojiText = Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text);
        
        XCTAssert(emojiText!.id == nil);
        XCTAssert(emojiText!.tnf == TypeNameFormat.wellKnown.rawValue);
        XCTAssert(emojiText!.type == TextRecord.recordType);
        XCTAssert(emojiText!.textEncoding == TextEncodingType.Utf16);
        XCTAssert(emojiText!.languageCode == languageCode);
        XCTAssert(emojiText!.text == text);
    }
    
    func testUnicodeEmojiUtf8() {
        let text: String = "🤠👀💅🤩🐸🍵";
        let textEncoding = TextEncodingType.Utf8;
        let languageCode : String = "fr";
        
        XCTAssertNotNil(Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text));
        let emojiText = Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text);
        
        XCTAssert(emojiText!.id == nil);
        XCTAssert(emojiText!.tnf == TypeNameFormat.wellKnown.rawValue);
        XCTAssert(emojiText!.type == TextRecord.recordType);
        XCTAssert(emojiText!.textEncoding == TextEncodingType.Utf8);
        XCTAssert(emojiText!.languageCode == languageCode);
        XCTAssert(emojiText!.text == text);
        //NSLog("\(String(describing: emojiText!.text))");
    }
    
    
    func testDuplicateRecord() {
        let helloWorldPayload : [UInt8] = [0x02, 0x65, 0x6E, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21, 0x21, 0x21];
        
        let textRecord = Ndef.makeTextRecord(payload: helloWorldPayload);
        XCTAssertNotNil(Ndef.makeTextRecord(other: textRecord!));
        let duplicate = Ndef.makeTextRecord(other: textRecord!);
        XCTAssert(duplicate.payload == helloWorldPayload);
    }
    
    func testIsRecordType() {
        let textRecord = Ndef.makeTextRecord(payload: [0x02, 0x65, 0x6E]);
        XCTAssertTrue(TextRecord.isRecordType(record: textRecord!));
        
        XCTAssertFalse(TextRecord.isRecordType(record: Ndef.makeUriRecord()));
        
        let genericRecord = Ndef.makeGenericRecord(tnf: TypeNameFormat.mimeMedia, type: [], payload: []);
        XCTAssertFalse(TextRecord.isRecordType(record: genericRecord));
    }
    
    func testErrors() {
        let textEncoding = TextEncodingType.Utf8;
        
        // No error: max language code length.
        var maxLengthLanguageCode : String = "";
        for _ in 0..<TextRecord.languageCodeMaxLength {
            maxLengthLanguageCode += "a";
        }
        XCTAssertNotNil(Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: maxLengthLanguageCode, text: ""));
        
        // Error: language code exceeds max length.
        var exceedMaxLengthLanguageCode : String = "";
        for _ in 0...TextRecord.languageCodeMaxLength {
            exceedMaxLengthLanguageCode += "a";
        }
        XCTAssertNil(Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: exceedMaxLengthLanguageCode, text: ""));
        
        // Error: language code cannot be omitted.
        XCTAssertNil(Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: "", text: ""));
        
        // Error: Payload is not long enough to contain specified language code length.
        let tooShortPayload : [UInt8] = [0x02, 0x65];
        XCTAssertNil(Ndef.makeTextRecord(payload: tooShortPayload));
        
        // No error: payload contains only status byte and language code.
        let noTextPayload : [UInt8] = [0x02, 0x65, 0x6E];
        XCTAssertNotNil(Ndef.makeTextRecord(payload: noTextPayload));
    }
    
    
    func testMutators() {
        let textEncoding = TextEncodingType.Utf8;
        let languageCode = "en";
        let text = "hello";
        
        XCTAssertNotNil(Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text));
        let textRecord = Ndef.makeTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text);
        
        // Mutate id
        let newId : [UInt8] = [0x02];
        textRecord!.id = newId;
        XCTAssert(textRecord!.id! == newId);
        
        // Mutate text encoding
        let newTextEncoding = TextEncodingType.Utf16;
        textRecord!.textEncoding = newTextEncoding;
        XCTAssert(textRecord!.textEncoding == newTextEncoding);
        XCTAssert(textRecord!.languageCode == languageCode);
        XCTAssert(textRecord!.text == text);
        XCTAssert(textRecord!.textLength == text.count);
        
        // Mutate language code
        let newLanguageCode = "fr";
        textRecord!.languageCode = newLanguageCode;
        XCTAssert(textRecord!.textEncoding == newTextEncoding);
        XCTAssert(textRecord!.languageCode == newLanguageCode);
        XCTAssert(textRecord!.text == text);
        XCTAssert(textRecord!.textLength == text.count);
        
        // Mutate text
        let newText = "hello world";
        textRecord!.text = newText;
        XCTAssert(textRecord!.textEncoding == newTextEncoding);
        XCTAssert(textRecord!.languageCode == newLanguageCode);
        XCTAssert(textRecord!.text == newText);
        XCTAssert(textRecord!.textLength == newText.count);
        
        // Mutate payload
        let newPayload : [UInt8] = [0x02, 0x65, 0x6E];
        textRecord!.payload = newPayload;
        XCTAssert(textRecord!.payload == newPayload);
        XCTAssert(textRecord!.textEncoding == TextEncodingType.Utf8);
        XCTAssert(textRecord!.languageCode == "en");
        XCTAssert(textRecord!.text == "");
        XCTAssert(textRecord!.textLength == 0);
    }
    
}
