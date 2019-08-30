//
//  TextRecord.swift
//  NdefLibrary
//
//  Created by Alice Cai on 2019-05-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

// Text encoding type - either Utf8 or Utf16 (Big Endian).
// If the Unicode Byte-Order-Mark (BOM) is omitted, the byte order will be Utf16 BE.
@objc public enum TextEncodingType: UInt8 {
    case Utf8, Utf16
}

public enum TextRecordValidationError: Error {
    case languageCodeExceedsMaxLength
    case languageCodeMissing
    case payloadTooShort
    case payloadTooLong
}

@objc public class TextRecord: NSObject, NdefRecord {
    // The type of an NDEF text record is "T" (binary encoding is 0x54).
    @objc public static let recordType: [UInt8] = [0x54]
    
    // first bit of status byte indicates encoding type 0 means UTF-8
    internal static let textEncodingTypeMask: UInt8 = 0b10000000
    
    // The language code length is encoded in the six least significant bits of the status byte.
    internal static let languageCodeLengthMask: UInt8 = 0b00111111
    internal static let languageCodeMaxLength: Int = 63
    
    
    // MARK: - Required fields
    @objc public private(set) var tnf: UInt8 = TypeNameFormat.wellKnown.rawValue
    
    @objc public private(set) var type: [UInt8] = TextRecord.recordType
    
    private var _id: [UInt8]? = nil
    @objc public var id: [UInt8]? {
        get {
            if (_id == nil) {
                return nil
            }
            return _id!
        }
        
        set {
            _id = newValue
        }
    }
    
    private var _payload: [UInt8] = []
    @objc public var payload: [UInt8] {
        get {
            return _payload
        }
        
        set {
            _payload = newValue
        }
    }
    
    
    // MARK: - Record-specific fields
    
    @objc public var textEncoding: TextEncodingType {
        get {
            if (payload.count == 0) {
                return TextEncodingType.Utf8 // default
            }
            let encodingType = payload[0] & TextRecord.textEncodingTypeMask
            return encodingType == 0 ? TextEncodingType.Utf8: TextEncodingType.Utf16
        }
        
        set {
            updatePayload(textEncoding: newValue, languageCode: languageCode, text: text)
        }
    }
    
    // Language code of the text. All language codes must be done according to [RFC5646].
    // The language code may not be omitted.
    @objc public var languageCode: String {
        get {
            if (payload.count == 0) {
                return "en" // Default language code.
            }
            
            let statusByte = payload[0]
            let codeLength = Int(statusByte & TextRecord.languageCodeLengthMask)
            
            let code = payload[1...codeLength]
            let codeString = String(bytes: code, encoding: .utf8)
            
            if codeString != nil {
                return codeString!
            }
            return "en"
        }
        
        set {
            updatePayload(textEncoding: textEncoding, languageCode: newValue, text: text)
        }
    }
    
    @objc public var text: String {
        get {
            if (payload.count == 0) {
                return ""
            }
            
            //let encoding: String.Encoding = (textEncoding == TextEncodingType.Utf8) ? String.Encoding.utf8 : String.Encoding.utf16
            let encoding = String.Encoding.utf8
            let codeLength = Int(payload[0] & TextRecord.languageCodeLengthMask)
            
            let textStartIndex: Int = codeLength + 1
            let _text = String(bytes: _payload[textStartIndex...], encoding: encoding)
            
            if _text != nil {
                return _text!
            }
            return ""
        }
        
        set {
            updatePayload(textEncoding: textEncoding, languageCode: languageCode, text: newValue)
        }
    }
    
    @objc public var textLength: Int {
        get {
            return text.count
        }
    }
    
    
    // MARK: - Constructors
    
    internal init(other: TextRecord) {
        super.init()
        
        if other.id == nil {
            _id = nil
        } else {
            _id = other.id!
        }
        _payload = other.payload
    }
    
    internal init(payload: [UInt8], id: [UInt8]?) throws {
        super.init()
        
        if payload.count > UInt32.max {
            throw TextRecordValidationError.payloadTooLong
        }
        
        if id == nil {
            _id = nil
        } else {
            _id = id!
        }
        _payload = payload
        
        let statusByte = payload[0]
        let languageCodeLength = Int(statusByte & TextRecord.languageCodeLengthMask)
        
        guard languageCodeLength > 0 else {
            throw TextRecordValidationError.languageCodeMissing
        }
        
        // minimum payload length is length of language code + length of status byte
        guard payload.count >= languageCodeLength + 1 else {
            throw TextRecordValidationError.payloadTooShort
        }
    }
    
    internal convenience init(payload: [UInt8]) throws {
        try self.init(payload: payload, id: nil)
    }
    
    internal init(textEncoding: TextEncodingType, languageCode: String, text: String, id: String?) throws {
        super.init()
        if id == nil {
            _id = nil
        } else {
            _id = Array(id!.utf8)
        }
        
        guard languageCode.count > 0 else {
            throw TextRecordValidationError.languageCodeMissing
        }
        
        guard languageCode.count <= TextRecord.languageCodeMaxLength else {
            throw TextRecordValidationError.languageCodeExceedsMaxLength
        }
        
        updatePayload(textEncoding: textEncoding, languageCode: languageCode, text: text)
    }
    
    internal convenience init(textEncoding: TextEncodingType, languageCode: String, text: String) throws {
        try self.init(textEncoding: textEncoding, languageCode: languageCode, text: text, id: nil)
    }
    
    
    // MARK: - Methods
    
    private func updatePayload(textEncoding: TextEncodingType, languageCode: String, text: String) {
        var newPayload: [UInt8] = []
        
        // assemble status byte
        var statusByte: UInt8 = 0 // RFU must be set to zero
        if textEncoding == TextEncodingType.Utf8 {
            statusByte &= TextRecord.textEncodingTypeMask // 0 is UTF-8
        } else {
            statusByte |= TextRecord.textEncodingTypeMask
        }
        statusByte |= UInt8(TextRecord.languageCodeLengthMask & UInt8(languageCode.count))
        newPayload.append(statusByte)
        
        // encode language code
        let encodedLanguageCode: [UInt8] = Array(languageCode.utf8)
        newPayload += encodedLanguageCode
        
        // encode actual text
        if text.count > 0 {
            let encodedText = Array(text.utf8)
            newPayload += encodedText
        }
        
        _payload = newPayload
    }
    
    @objc public static func isRecordType(record: NdefRecord?) -> Bool {
        if (record == nil) {
            return false
        }
        
        if (record as? TextRecord) != nil {
            return true
        }
        return false
    }
}
