//
//  UriRecord.swift
//  NdefLibrary
//
//  Created by Alice Cai on 2019-05-10.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

@objc
public class UriRecord : NSObject, NdefRecord {
    // The type of an NDEF URI record is "U" (binary encoding is 0x55).
    public static let RecordType : [UInt8] = [0x55];
    
    public enum UriRecordValidationError : Error {
        case payloadTooLong
    }
    
    public static let PrefixProtocols : [String] =
        ["",
         "http://www.",
         "https://www.",
         "http://",
         "https://",
         "tel:",
         "mailto:",
         "ftp://anonymous:anonymous@",
         "ftp://ftp.",
         "ftps://",
         "sftp://",
         "smb://",
         "nfs://",
         "ftp://",
         "dav://",
         "news:",
         "telnet://",
         "imap:",
         "rtsp://",
         "urn:",
         "pop:",
         "sip:",
         "sips:",
         "tftp:",
         "btspp://",
         "btl2cap://",
         "btgoep://",
         "tcpobex://",
         "irdaobex://",
         "file://",
         "urn:epc:id:",
         "urn:epc:tag:",
         "urn:epc:pat:",
         "urn:epc:raw:",
         "urn:epc:",
         "urn:nfc:"];
    
    
    /* Required fields */
    
    public var tnf : UInt8 {
        get {
            return Ndef.TypeNameFormat.wellKnown.rawValue;
        }
    }
    
    public var type: [UInt8] {
        get {
            return UriRecord.RecordType;
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
    
    
    public var rawUri : [UInt8] {
        get {
            if payload.count == 0 {
                return [];
            }
            
            var rawUri : [UInt8] = payload;
            rawUri.removeFirst(1); // remove protocol prefix
            return rawUri;
        }
    }
    
    public var uri : String {
        get {
            if payload.count == 0 {
                return "";
            }
            
            let identifierCode = payload[0];
            let protocolPrefix = UriRecord.GetProtocolFromCode(identifierCode);
            
            let uriString = String(bytes: payload[1..<payload.count], encoding: .utf8);
            
            if uriString != nil {
                return protocolPrefix + uriString!;
            }
            return protocolPrefix;
        }
        
        set(newUri) {
            let identifierCode = UriRecord.GetCodeFromUri(newUri);
            
            let protocolLength : Int = UriRecord.PrefixProtocols[Int(identifierCode)].count;
            
            // substring the uri to get just the uri field from the string
            let uriStartIndex = newUri.index(newUri.startIndex, offsetBy: protocolLength);
            let newRawUri = String(newUri[uriStartIndex...]);
            
            // payload is identifier code + encoded uri field
            var newPayload : [UInt8] = [identifierCode];
            newPayload += Array(newRawUri.utf8); // convert to binary
            
            payload = newPayload;
        }
    }
    
    
    /* Constructors  */
    
    internal override init() {
        super.init();
    }
    
    internal init(other: UriRecord) {
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
            throw UriRecordValidationError.payloadTooLong;
        }
        
        if id == nil {
            _id = nil;
        } else {
            _id = id!;
        }
        _payload = payload;
    }
    
    internal convenience init(payload: [UInt8]) throws {
        let id : [UInt8]? = nil;
        try self.init(payload: payload, id: id);
    }
    
    internal init(uri: String, id: String?) {
        super.init();
        if id == nil {
            _id = nil;
        } else {
            _id = Array(id!.utf8);
        }
        
        self.uri = uri;
    }
    
    internal convenience init(uri: String) {
        self.init(uri: uri, id: nil);
    }
    
    
    /* Methods */
    
    public static func isRecordType(record: NdefRecord?) -> Bool {
        if (record == nil) {
            return false;
        }
        
        if (record as? UriRecord) != nil {
            return true;
        }
        return false;
    }
    
    private static func GetCodeFromUri(_ uri: String) -> UInt8 {
        for i in 1 ..< PrefixProtocols.count {
            if uri.starts(with: PrefixProtocols[i]) {
                return UInt8(i);
            }
        }
        return 0x00;
    }
    
    private static func GetProtocolFromCode(_ identifierCode: UInt8) -> String {
        if identifierCode >= 0 && identifierCode < PrefixProtocols.count {
            return PrefixProtocols[Int(identifierCode)];
        }
        return "";
    }
}
