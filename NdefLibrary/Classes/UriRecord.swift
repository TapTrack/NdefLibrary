//
//  UriRecord.swift
//  NdefLibrary
//
//  Created by Alice Cai on 2019-05-10.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

public enum UriRecordValidationError: Error {
    case payloadTooLong
}

@objc public class UriRecord: NSObject, NdefRecord {
    // The type of an NDEF URI record is "U" (binary encoding is 0x55).
    @objc public static let recordType: [UInt8] = [0x55]
    
    @objc public static let prefixProtocols: [String] =
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
         "urn:nfc:"]
    
    
    // MARK: - Required fields
    
    @objc public private(set) var tnf: UInt8 = TypeNameFormat.wellKnown.rawValue
    
    @objc public private(set) var type: [UInt8] = UriRecord.recordType
    
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
    
    
    @objc public var uri: [UInt8] {
        get {
            if payload.count == 0 {
                return []
            }
            
            var _uri: [UInt8] = payload
            _uri.removeFirst(1) // remove protocol prefix
            return _uri
        }
    }
    
    @objc public var uriString: String {
        get {
            if payload.count == 0 {
                return ""
            }
            
            let identifierCode = payload[0]
            let protocolPrefix = UriRecord.getProtocolFromCode(identifierCode)
            
            let _uriString = String(bytes: payload[1..<payload.count], encoding: .utf8)
            
            if _uriString != nil {
                return protocolPrefix + _uriString!
            }
            return protocolPrefix
        }
        
        set(newUri) {
            let identifierCode = UriRecord.getCodeFromUri(newUri)
            
            let protocolLength: Int = UriRecord.prefixProtocols[Int(identifierCode)].count
            
            // substring the uri to get just the uri field from the string
            let uriStartIndex = newUri.index(newUri.startIndex, offsetBy: protocolLength)
            let newRawUri = String(newUri[uriStartIndex...])
            
            // payload is identifier code + encoded uri field
            var newPayload: [UInt8] = [identifierCode]
            newPayload += Array(newRawUri.utf8) // convert to binary
            
            payload = newPayload
        }
    }
    
    
    // MARK: - Constructors
    
    internal override init() {
        super.init()
    }
    
    internal init(other: UriRecord) {
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
            throw UriRecordValidationError.payloadTooLong
        }
        
        if id == nil {
            _id = nil
        } else {
            _id = id!
        }
        _payload = payload
    }
    
    internal convenience init(payload: [UInt8]) throws {
        let id: [UInt8]? = nil
        try self.init(payload: payload, id: id)
    }
    
    internal init(uri: String, id: String?) {
        super.init()
        if id == nil {
            _id = nil
        } else {
            _id = Array(id!.utf8)
        }
        
        self.uriString = uri
    }
    
    internal convenience init(uri: String) {
        self.init(uri: uri, id: nil)
    }
    
    
    // MARK: - Methods
    
    @objc public static func isRecordType(record: NdefRecord?) -> Bool {
        if (record == nil) {
            return false
        }
        
        if (record as? UriRecord) != nil {
            return true
        }
        return false
    }
    
    private static func getCodeFromUri(_ uri: String) -> UInt8 {
        for i in 1 ..< prefixProtocols.count {
            if uri.starts(with: prefixProtocols[i]) {
                return UInt8(i)
            }
        }
        return 0x00
    }
    
    private static func getProtocolFromCode(_ identifierCode: UInt8) -> String {
        if identifierCode >= 0 && identifierCode < prefixProtocols.count {
            return prefixProtocols[Int(identifierCode)]
        }
        return ""
    }
}
