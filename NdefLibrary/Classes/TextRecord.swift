//
//  TextRecord.swift
//  NdefLibrary
//
//  Created by Alice Cai on 2019-05-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

@objc
public class TextRecord : NSObject, NdefRecord {
    // The type of an NDEF text record is "T" (binary encoding is 0x54).
    public static let RecordType : [UInt8] = [0x54];
    
    // first bit of status byte indicates encoding type; 0 means UTF-8
    static let textEncodingTypeFlag : UInt8 = 0b10000000;
    
    // The language code length is encoded in the six least significant bits of the status byte.
    static let codeLengthFlag : UInt8 = 0b00111111;
    static let languageCodeMaxLength : Int = 63;
    
    
    // Text encoding type - either Utf8 or Utf16 (Big Endian).
    // If the Unicode Byte-Order-Mark (BOM) is omitted, the byte order will be Utf16 BE.
    public enum TextEncodingType {
        case Utf8, Utf16
    }
    
    public enum TextRecordValidationError : Error {
        case languageCodeExceedsMaxLength
        case languageCodeMissing
        case payloadTooShort
        case payloadTooLong
    }
    
    
    /* Required fields */
    
    public var tnf : UInt8 {
        get {
            return Ndef.TypeNameFormat.wellKnown.rawValue;
        }
    }
    
    public var type: [UInt8] {
        get {
            return TextRecord.RecordType;
        }
    }
    
    private var _id : [UInt8]? = nil;
    public var id: [UInt8]? {
        get {
            if (_id == nil) {
                return nil;
            }
            return _id!;
        }
        
        set {
            _id = newValue;
        }
    }
    
    private var _payload : [UInt8] = [];
    public var payload: [UInt8] {
        get {
            return _payload;
        }
        
        set {
            _payload = newValue;
        }
    }
    
    
    /* Record-specific fields */
    
    public var textEncoding : TextEncodingType {
        get {
            if (payload.count == 0) {
                return TextEncodingType.Utf8; // default
            }
            let encodingType = payload[0] & TextRecord.textEncodingTypeFlag;
            return encodingType == 0 ? TextEncodingType.Utf8 : TextEncodingType.Utf16;
        }
        
        set {
            updatePayload(textEncoding: newValue, languageCode: languageCode, text: text);
        }
    }
    
    // Language code of the text. All language codes must be done according to [RFC5646].
    // The language code may not be omitted.
    public var languageCode : String {
        get {
            if (payload.count == 0) {
                return "en"; // Default language code.
            }
            
            let statusByte = payload[0];
            let codeLength = Int(statusByte & TextRecord.codeLengthFlag);
            
            let code = payload[1...codeLength];
            let codeString = String(bytes: code, encoding: .utf8);
            
            if codeString != nil {
                return codeString!;
            }
            return "en";
        }
        
        set {
            updatePayload(textEncoding: textEncoding, languageCode: newValue, text: text);
        }
    }
    
    public var text : String {
        get {
            if (payload.count == 0) {
                return "";
            }
            
            //let encoding : String.Encoding = (textEncoding == TextEncodingType.Utf8) ? String.Encoding.utf8 : String.Encoding.utf16;
            let encoding = String.Encoding.utf8;
            let codeLength = Int(payload[0] & TextRecord.codeLengthFlag);
            
            let textStartIndex : Int = codeLength + 1;
            let _text = String(bytes: _payload[textStartIndex...], encoding: encoding);
            
            if _text != nil {
                return _text!;
            }
            return "";
        }
        
        set {
            updatePayload(textEncoding: textEncoding, languageCode: languageCode, text: newValue);
        }
    }
    
    public var textLength : Int {
        get {
            return text.count;
        }
    }
    
    
    /* Constructors */
    
    // failable initializer: returns nil if the argument is not a TextRecord object
    internal init(other: TextRecord) {
        super.init();
        
        if other.id == nil {
            _id = nil;
        } else {
            _id = other.id!;
        }
        _payload = other.payload;
    }
    
    internal init(payload: [UInt8], id: [UInt8]?) throws {
        super.init();
        
        if payload.count > UInt32.max {
            throw TextRecordValidationError.payloadTooLong;
        }
        
        if id == nil {
            _id = nil;
        } else {
            _id = id!;
        }
        _payload = payload;
        
        let statusByte = payload[0]
        let languageCodeLength = Int(statusByte & TextRecord.codeLengthFlag);
        
        guard languageCodeLength > 0 else {
            throw TextRecordValidationError.languageCodeMissing;
        }
        
        // minimum payload length is length of language code + length of status byte
        guard payload.count >= languageCodeLength + 1 else {
            throw TextRecordValidationError.payloadTooShort;
        }
    }
    
    internal convenience init(payload: [UInt8]) throws {
        try self.init(payload: payload, id: nil);
    }
    
    internal init(textEncoding: TextEncodingType, languageCode: String, text: String, id: String?) throws {
        super.init();
        if id == nil {
            _id = nil;
        } else {
            _id = Array(id!.utf8);
        }
        
        guard languageCode.count > 0 else {
            throw TextRecordValidationError.languageCodeMissing;
        }
        
        guard languageCode.count <= TextRecord.languageCodeMaxLength else {
            throw TextRecordValidationError.languageCodeExceedsMaxLength;
        }
        
        updatePayload(textEncoding: textEncoding, languageCode: languageCode, text: text);
    }
    
    internal convenience init(textEncoding: TextEncodingType, languageCode: String, text: String) throws {
        try self.init(textEncoding: textEncoding, languageCode: languageCode, text: text, id: nil);
    }
    
    
    /* Methods */
    
    //    private func convertToUInt8(encodedText encodedTextUtf16: [UInt16]) -> [UInt8] {
    //        var encodedTextUInt8 : [UInt8] = [];
    //
    //        for i in 0..<encodedTextUtf16.count {
    //            let firstByte = UInt8(encodedTextUtf16[i] >> 8 & 0b11111111);
    //            encodedTextUInt8.append(firstByte);
    //
    //            let secondByte = UInt8(encodedTextUtf16[i] & 0b11111111);
    //            encodedTextUInt8.append(secondByte);
    //        }
    //
    //        return encodedTextUInt8;
    //    }
    
    private func updatePayload(textEncoding: TextEncodingType, languageCode: String, text: String) {
        var newPayload : [UInt8] = [];
        
        // assemble status byte
        var statusByte : UInt8 = 0; // RFU must be set to zero
        if textEncoding == TextEncodingType.Utf8 {
            statusByte &= TextRecord.textEncodingTypeFlag; // 0 is UTF-8
        } else {
            statusByte |= TextRecord.textEncodingTypeFlag;
        }
        statusByte |= UInt8(TextRecord.codeLengthFlag & UInt8(languageCode.count));
        newPayload.append(statusByte);
        
        // encode language code
        let encodedLanguageCode : [UInt8] = Array(languageCode.utf8);
        newPayload += encodedLanguageCode;
        
        // encode actual text
        if text.count > 0 {
            //            let utf8Encoding = textEncoding == TextEncodingType.Utf8;
            //            var encodedText : [UInt8] = [];
            //            if utf8Encoding {
            //                encodedText = Array(text.utf8);
            //            } else {
            //                let encodedTextUtf16 = Array(text.utf16);
            //                encodedText = convertToUInt8(encodedText: encodedTextUtf16);
            //            }
            let encodedText = Array(text.utf8);
            newPayload += encodedText;
        }
        
        _payload = newPayload;
    }
    
    public static func isRecordType(record: NdefRecord?) -> Bool {
        if (record == nil) {
            return false;
        }
        
        if (record as? TextRecord) != nil {
            return true;
        }
        return false;
    }
}
