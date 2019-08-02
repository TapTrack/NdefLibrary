//
//  GenericRecord.swift
//  NdefLibrary
//
//  Created by Alice Cai on 2019-05-24.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

@objc
public class GenericRecord : NSObject, NdefRecord {
    public enum GenericRecordValidationError : Error {
        case payloadTooLong
    }
    
    private var _tnf : UInt8 = 0;
    public private(set) var tnf: UInt8 {
        get {
            return _tnf;
        }
        
        set {
            _tnf = newValue;
        }
    }
    
    private var _type : [UInt8] = [];
    public private(set) var type: [UInt8] {
        get {
            return _type;
        }
        
        set {
            _type = newValue;
        }
    }
    
    private var _id : [UInt8]? = nil;
    public private(set) var id: [UInt8]? {
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
    public private(set) var payload: [UInt8] {
        get {
            return _payload;
        }
        
        set {
            _payload = newValue;
        }
    }
    
    
    /* Constructors */
    
    internal init(other: NdefRecord) {
        _tnf = other.tnf;
        _type = other.type
        if other.id == nil {
            _id = nil;
        } else {
            _id = other.id!;
        }
        _payload = other.payload;
    }
    
    internal init(tnf: UInt8, type: [UInt8], payload: [UInt8], id: [UInt8]?) throws {
        if payload.count > UInt32.max {
            throw GenericRecordValidationError.payloadTooLong;
        }
        
        _tnf = tnf;
        _type = type
        if id == nil {
            _id = nil;
        } else {
            _id = id!;
        }
        _payload = payload;
    }
    
    internal convenience init(tnf: UInt8, type: [UInt8], payload: [UInt8]) throws {
        try self.init(tnf: tnf, type: type, payload: payload, id: nil);
    }
    
    
    /* Methods */
    
    public static func isRecordType(record: NdefRecord?) -> Bool {
        if (record == nil) {
            return false;
        }
        
        if (record as? GenericRecord) != nil {
            return true;
        }
        return false;
    }
}
