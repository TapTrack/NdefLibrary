//
//  Ndef.swift
//  NdefLibrary
//
//  Created by Alice Cai on 2019-07-24.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation
@objc

public final class Ndef : NSObject {
    // All valid values for the TNF field of an NDEF record (the TNF value is
    // indicated by the three least significant bits of the first record byte).
    public enum TypeNameFormat : UInt8 {
        case empty = 0x00
        case wellKnown = 0x01
        case mimeMedia = 0x02
        case absoluteUri = 0x03
        case external = 0x04
        case unknown = 0x05
        case unchanged = 0x06
        case reserved = 0x07
    }
    
    
    /* Text record methods */
    
    /**
     Creates a TextRecord by copying the fields of an existing TextRecord object.
     
     - Parameter other: The TextRecord object being copied.
     
     - Returns: A new TextRecord object with the same fields as the argument TextRecord object.
     */
    public static func CreateTextRecord(other: TextRecord) -> TextRecord {
        return TextRecord(other: other);
    }
    
    
    /**
     Creates a TextRecord object.
     
     - Parameter payload: Byte array representing the text record's payload.
     - Parameter id: Byte array representing the text record's id.
     
     - Returns: A new TextRecord object with the specified fields or nil if the fields
     are invalid.
     */
    public static func CreateTextRecord(payload: [UInt8], id: [UInt8]?) -> TextRecord? {
        do {
            return (id == nil) ? try TextRecord(payload: payload) :
                try TextRecord(payload: payload, id: id);
        } catch TextRecord.TextRecordValidationError.languageCodeMissing {
            print("Error: Language code cannot be omitted.");
        } catch TextRecord.TextRecordValidationError.languageCodeExceedsMaxLength {
            print("Error: Language code exceeds maximum length.");
        } catch TextRecord.TextRecordValidationError.payloadTooShort {
            print("Error: Payload is not long enough to contain specified language code length.");
        } catch TextRecord.TextRecordValidationError.payloadTooLong {
            print("Error: Payload exceeds maximum length.");
        } catch {
            print("Unexpected error: \(error).");
        }
        return nil;
    }
    
    
    /**
     Creates a TextRecord object.
     
     - Parameter payload: Byte array representing the text record's payload.
     
     - Returns: A new TextRecord object with the specified payload or nil if the payload is invalid.
     */
    public static func CreateTextRecord(payload: [UInt8]) -> TextRecord? {
        return CreateTextRecord(payload: payload, id: nil);
    }
    
    
    /**
     Creates a TextRecord object.
     
     - Parameter textEncoding: Indicates the text encoding being used on the record text. Must be one of
     TextRecord.TextEncodingType.Utf8 or TextRecord.TextEncodingType.Utf16.
     - Parameter languageCode: Indicates the language of the text. All language codes should be done
     according to [RFC5646], though this is not validated by the code.
     - Parameter text: The text to be encoded.
     - Parameter id: Optional record identifier.
     
     - Returns: A new TextRecord object with the specified information or nil if the information is invalid.
     */
    public static func CreateTextRecord(textEncoding: TextRecord.TextEncodingType, languageCode: String,
                                        text: String, id: String?) -> TextRecord? {
        do {
            return try TextRecord(textEncoding: textEncoding, languageCode: languageCode,
                                  text: text, id: id);
        } catch TextRecord.TextRecordValidationError.languageCodeMissing {
            print("Error: Language code cannot be omitted.");
        } catch TextRecord.TextRecordValidationError.languageCodeExceedsMaxLength {
            print("Error: Language code exceeds maximum length.");
        } catch {
            print("Unexpected error: \(error).");
        }
        return nil;
    }
    
    
    /**
     Creates a TextRecord object.
     
     - Parameter textEncoding: Indicates the text encoding being used on the record text. Must be one of
     TextRecord.TextEncodingType.Utf8 or TextRecord.TextEncodingType.Utf16.
     - Parameter languageCode: Indicates the language of the text. All language codes should be done
     according to [RFC5646], though this is not validated by the code.
     - Parameter text: The text to be encoded.
     
     - Returns: A new TextRecord object with the specified information or nil if the information is invalid.
     */
    public static func CreateTextRecord(textEncoding: TextRecord.TextEncodingType, languageCode: String,
                                        text: String) -> TextRecord? {
        return CreateTextRecord(textEncoding: textEncoding, languageCode: languageCode, text: text, id: nil);
    }
    
    
    
    /* URI record methods */
    
    
    /**
     Creates a UriRecord object.
     
     - Returns: A UriRecord object with an empty payload.
     */
    public static func CreateUriRecord() -> UriRecord {
        return UriRecord();
    }
    
    
    /**
     Creates a UriRecord by copying the fields of an existing UriRecord object.
     
     - Parameter other: The UriRecord object being copied.
     
     - Returns: A new UriRecord object with the same fields as the argument UriRecord object.
     */
    public static func CreateUriRecord(other: UriRecord) -> UriRecord {
        return UriRecord(other: other);
    }
    
    
    /**
     Creates a UriRecord object.
     
     - Parameter payload: Byte array representing the uri record's payload.
     - Parameter id: Byte array representing the uri record's id.
     
     - Returns: A new UriRecord object with the specified fields or nil if the
     fields are invalid.
     */
    public static func CreateUriRecord(payload: [UInt8], id: [UInt8]?) -> UriRecord? {
        do {
            return try UriRecord(payload: payload, id: id);
        } catch UriRecord.UriRecordValidationError.payloadTooLong {
            print("Error: payload exceeds maximum length.");
        } catch {
            print("Unexpected error: \(error).");
        }
        
        return nil;
    }
    
    
    /**
     Creates a UriRecord object.
     
     - Parameter payload: Byte array representing the uri record's payload.
     
     - Returns: A new UriRecord object with the specified payload or nil if the payload
     argument is invalid.
     */
    public static func CreateUriRecord(payload: [UInt8]) -> UriRecord? {
        return CreateUriRecord(payload: payload, id: nil);
    }
    
    
    /**
     Creates a UriRecord object.
     
     - Parameter uri: String representing the raw uri of the record.
     - Parameter id: String representing the record identifier.
     
     - Returns: A new UriRecord object with the specified payload or nil if the payload
     argument is invalid.
     */
    public static func CreateUriRecord(uri: String, id: String?) -> UriRecord {
        return UriRecord(uri: uri, id: id);
    }
    
    
    /**
     Creates a UriRecord object.
     
     - Parameter uri: String representing the raw uri of the record.
     
     - Returns: A new UriRecord object with the specified information.
     */
    public static func CreateUriRecord(uri: String) -> UriRecord {
        return CreateUriRecord(uri: uri, id: nil);
    }
    
    
    
    /* Generic record methods */
    
    
    /**
     Creates a GenericRecord by copying the fields of an existing GenericRecord object.
     
     - Parameter other: The GenericRecord object being copied.
     
     - Returns: A new GenericRecord object with the same fields as the argument GenericRecord object.
     */
    public static func CreateGenericRecord(other: GenericRecord) -> GenericRecord {
        return GenericRecord(other: other);
    }
    
    
    /**
     Creates a GenericRecord by copying the fields of an existing GenericRecord object.
     
     - Parameter tnf: Indicates the Type Name Format of the record. Must be a member of
     Ndef.TypeNameFormat.
     - Parameter type: A byte array representing the type of the record.
     - Parameter payload: A byte array representing the payload of the record.
     - Parameter id: Optional byte array representing the id of the record.
     
     - Returns: A new GenericRecord object with the specified fields.
     */
    public static func CreateGenericRecord(tnf: Ndef.TypeNameFormat, type: [UInt8],
                                           payload: [UInt8], id: [UInt8]?) -> GenericRecord? {
        do {
            return try GenericRecord(tnf: tnf.rawValue, type: type, payload: payload, id: id);
        } catch GenericRecord.GenericRecordValidationError.payloadTooLong {
            print("Error: payload exceeds maximum length.");
        } catch {
            print("Unexpected error: \(error).");
        }
        
        return nil;
    }
    
    
    /**
     Creates a GenericRecord by copying the fields of an existing GenericRecord object.
     
     - Parameter tnf: Indicates the Type Name Format of the record. Must be a member of
     Ndef.TypeNameFormat.
     - Parameter type: A byte array representing the type of the record.
     - Parameter payload: A byte array representing the payload of the record.
     
     - Returns: A new GenericRecord object with the specified fields.
     */
    public static func CreateGenericRecord(tnf: Ndef.TypeNameFormat, type: [UInt8], payload: [UInt8]) -> GenericRecord? {
        return CreateGenericRecord(tnf: tnf, type: type, payload: payload, id: nil);
    }
    
    
    
    /* NDEF message methods */
    
    
    /**
     Creates an empty NdefMessage object.
     
     - Returns: A new NdefMessage object with zero records.
     */
    public static func CreateNdefMessage() -> NdefMessage {
        return NdefMessage();
    }
    
    
    /**
     Creates an NdefMessage object.
     
     - Parameter records: An array of NdefRecord objects.
     
     - Returns: A new NdefMessage object containing the specified records.
     */
    public static func CreateNdefMessage(records: [NdefRecord]) -> NdefMessage {
        return NdefMessage(records: records);
    }
    
    
    /**
     Creates an NdefMessage object.
     
     - Parameter rawNdefMessage: An byte array representing one or more complete NDEF records.
     
     - Returns: A new NdefMessage object containing the specified records.
     */
    public static func CreateNdefMessage(rawByteArray: [UInt8]) -> NdefMessage? {
        do {
            return try NdefMessage(rawByteArray: rawByteArray);
        } catch let e as NdefMessage.MessageParsingError {
            print("NdefMessage parsing error at index \(e.index) of \(e.rawBytes): \(e.kind)");
        } catch {
            print("Error parsing NDEF message: \(error)");
        }
        
        return nil;
    }
}
