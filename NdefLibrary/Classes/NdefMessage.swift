//
//  NdefMessage.swift
//  NdefLibrary
//
//  Created by Alice Cai on 2019-07-25.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation
@objc

public class NdefMessage: NSObject {
    public struct MessageParsingError : Error {
        enum ErrorKind {
            case rawByteArrayTooShort
            case multipleMessageBeginFlags
            case messageBeginFlagMissing
            case multipleMessageEndFlags
            
            case chunkedRecordsNotSupported
            
            case typeLengthMissing
            case payloadLengthMissing
            case idLengthMissing
            case typeFieldMissing
            case idFieldMissing
            case payloadFieldMissing
        }
        
        let index : Int
        let rawBytes : [UInt8]
        let kind : ErrorKind
    }
    
    // NDEF record header flags
    @objc private static let messageBeginFlag : UInt8 = 0b10000000
    @objc private static let messageEndFlag : UInt8 = 0b01000000
    @objc private static let chunkedFlag : UInt8 = 0b00100000
    @objc private static let shortRecordFlag : UInt8 = 0b00010000
    @objc private static let idLengthPresentFlag : UInt8 = 0b00001000
    @objc private static let typeLengthFormatFlag : UInt8 = 0b00000111
    
    @objc private static let shortRecordLengthLength : Int = 1;
    @objc private static let longRecordLengthLength : Int = 4;
    
    // The shortest possible NDEF record is an empty short record with no ID.
    @objc private static let shortestPossibleNdefLength = 3
    
    
    /* Fields */
    
    private var _records : [NdefRecord] = [];
    public var records : [NdefRecord] {
        get {
            return _records;
        }
        
        set {
            _records = newValue;
        }
    }
    
    public var numRecords : Int {
        get {
            return _records.count;
        }
    }
    
    
    /* Constructors */
    
    internal override init() {
        super.init();
    }
    
    internal init(records: [NdefRecord]) {
        super.init();
        _records = records;
    }
    
    internal init(rawByteArray: [UInt8]) throws {
        super.init();
        let records : [NdefRecord] = try NdefMessage.FromByteArray(rawMessage: rawByteArray);
        _records = records;
    }
    
    
    /* Methods for modifying records array */
    
    public func appendRecord(record: NdefRecord) {
        _records.append(record);
    }
    
    public func insertRecord(record: NdefRecord, at index: Int) {
        _records.insert(record, at: index);
    }
    
    public func removeRecord(at index: Int) {
        if index < 0 || index >= _records.count {
            return;
        }
        _records.remove(at: index);
    }
    
    
    /* Methods for converting to and from raw byte array */
    
    private static func FromByteArray(rawMessage: [UInt8]) throws -> [NdefRecord] {
        let rawMessageLength = rawMessage.count;
        
        var foundMessageBegin = false;
        var foundMessageEnd = false;
        var recordStartIndex = 0;
        var ndefRecords: [NdefRecord] = [];
        
        guard rawMessageLength >= shortestPossibleNdefLength else {
            throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .rawByteArrayTooShort);
        }
        
        while recordStartIndex < rawMessageLength {
            let flagsAndTnf : UInt8 = rawMessage[recordStartIndex] // first byte of record header
            
            // Parse out flags and TNF from first byte of record header.
            let isMessageBegin : Bool = (flagsAndTnf & messageBeginFlag) != 0
            let isMessageEnd : Bool = (flagsAndTnf & messageEndFlag) != 0
            let isChunked = (flagsAndTnf & chunkedFlag) != 0
            let isShortRecord : Bool = (flagsAndTnf & shortRecordFlag) != 0
            let hasIdLength : Bool = (flagsAndTnf & idLengthPresentFlag) != 0
            let rawTypeNameFormat = flagsAndTnf & typeLengthFormatFlag
            let typeNameFormat : Ndef.TypeNameFormat =
                Ndef.TypeNameFormat(rawValue: rawTypeNameFormat) ?? Ndef.TypeNameFormat.unknown
            
            // Other record header fields.
            var typeLength : Int = 0;
            var payloadLength : Int = 0;
            var idLength : Int = 0;
            
            // Record fields.
            var type : [UInt8] = [];
            var id : [UInt8]? = nil;
            var payload : [UInt8] = [];
            
            if isChunked {
                throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .chunkedRecordsNotSupported);
            }
            
            if isMessageBegin && !foundMessageBegin {
                foundMessageBegin = true;
            } else if isMessageBegin && foundMessageBegin {
                throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .multipleMessageBeginFlags);
            } else if !isMessageBegin && !foundMessageBegin {
                throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .messageBeginFlagMissing);
            }
            
            if isMessageEnd && !foundMessageEnd {
                foundMessageEnd = true;
            } else if isMessageEnd && foundMessageEnd {
                throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .multipleMessageEndFlags);
            }
            
            // Type length is always the second byte in record.
            let typeLengthIndex = recordStartIndex + 1;
            guard typeLengthIndex < rawMessageLength else {
                throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .typeLengthMissing);
            }
            typeLength = Int(rawMessage[typeLengthIndex]);
            
            // Calculate length of payload. Payload length is a required field that always directly follows
            // the type length field.
            let payloadLengthStart = typeLengthIndex + 1;
            var payloadLengthEnd = payloadLengthStart;
            if isShortRecord {
                guard payloadLengthStart < rawMessageLength else {
                    throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .payloadLengthMissing);
                }
                payloadLength = Int(rawMessage[payloadLengthStart])
            } else {
                payloadLengthEnd = payloadLengthStart + longRecordLengthLength - 1;
                
                guard payloadLengthEnd < rawMessageLength else {
                    throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .payloadLengthMissing);
                }
                
                let payloadLengthBinary = Array(rawMessage[payloadLengthStart...payloadLengthEnd]);
                let payloadLengthData = Data(bytes: payloadLengthBinary);
                payloadLength = Int(UInt32(bigEndian: payloadLengthData.withUnsafeBytes { $0.pointee }));
            }
            
            // Id length is always the last mandatory header field (if IL flag is set).
            var idLengthIndex = payloadLengthEnd;
            if hasIdLength {
                idLengthIndex += 1;
                guard idLengthIndex < rawMessageLength else {
                    throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .idLengthMissing);
                }
                idLength = Int(rawMessage[idLengthIndex]);
            } else {
                idLength = 0;
            }
            
            var typeIndex = idLengthIndex;
            if typeLength > 0 {
                typeIndex += 1;
                guard typeIndex < rawMessageLength else {
                    throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .typeFieldMissing);
                }
                type = Array(rawMessage[typeIndex..<(typeIndex + typeLength)]);
            }
            
            var idIndex = typeIndex;
            if idLength > 0 {
                idIndex += 1;
                guard idIndex < rawMessageLength else {
                    throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .idFieldMissing);
                }
                id = Array(rawMessage[idIndex..<(idIndex + idLength)]);
            }
            
            var payloadEndIndex = idIndex;
            if payloadLength > 0 {
                let payloadStartIndex = idIndex + 1;
                payloadEndIndex = idIndex + payloadLength;
                guard payloadEndIndex < rawMessageLength else {
                    throw MessageParsingError(index: recordStartIndex, rawBytes: rawMessage, kind: .payloadFieldMissing);
                }
                payload = Array(rawMessage[payloadStartIndex...payloadEndIndex]);
            }
            
            var record : NdefRecord? = nil;
            if typeNameFormat == Ndef.TypeNameFormat.wellKnown {
                if type == TextRecord.RecordType {
                    record = Ndef.CreateTextRecord(payload: payload, id: id);
                } else if type == UriRecord.RecordType {
                    record = Ndef.CreateUriRecord(payload: payload, id: id);
                }
            }
            if record == nil {
                record = Ndef.CreateGenericRecord(tnf: typeNameFormat, type: type, payload: payload, id: id);
            }
            ndefRecords.append(record!);
            
            if foundMessageEnd {
                break;
            }
            
            recordStartIndex = payloadEndIndex + 1;
        }
        
        return ndefRecords;
    }
    
    public func toByteArray() -> [UInt8] {
        var rawMessage : [UInt8] = [];
        
        for i in 0..<numRecords {
            let rawRecord : [UInt8] = _records[i].toByteArray(
                messageBegin: i == 0,
                messageEnd: i == numRecords - 1,
                chunked: false
            );
            rawMessage.append(contentsOf: rawRecord);
        }
        
        return rawMessage;
    }
    
}
