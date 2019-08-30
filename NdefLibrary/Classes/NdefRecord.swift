//
//  NdefRecord.swift
//  NdefLibrary
//
//  Created by Alice Cai on 2019-05-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

// All valid values for the TNF field of an NDEF record (the TNF value is
// indicated by the three least significant bits of the first record byte).
@objc public enum TypeNameFormat: UInt8 {
    case empty = 0x00
    case wellKnown = 0x01
    case mimeMedia = 0x02
    case absoluteUri = 0x03
    case external = 0x04
    case unknown = 0x05
    case unchanged = 0x06
    case reserved = 0x07
}

@objc public protocol NdefRecord {
    var tnf: UInt8 { get }
    var type: [UInt8] { get }
    var id: [UInt8]? { get }
    var payload: [UInt8] { get }

    static func isRecordType (record: NdefRecord?) -> Bool
}

public extension NdefRecord {
    private func constructFlagsAndTnf(messageBegin: Bool, messageEnd: Bool, chunked: Bool,
                                      short: Bool, idPresent: Bool) -> UInt8 {
        // NDEF record header bit masks
        let messageBeginMask: UInt8 = 0b10000000
        let messageEndMask: UInt8 = 0b01000000
        let chunkedMask: UInt8 = 0b00100000
        let shortRecordMask: UInt8 = 0b00010000
        let idPresentMask: UInt8 = 0b00001000
        
        var flagsAndTnf: UInt8 = tnf
        
        func set (flag: UInt8, to set: Bool) {
            if set {
                flagsAndTnf |= flag
            }
        }
        
        set(flag: messageBeginMask, to: messageBegin)
        set(flag: messageEndMask, to: messageEnd)
        set(flag: chunkedMask, to: chunked)
        set(flag: shortRecordMask, to: short)
        set(flag: idPresentMask, to: idPresent)
        
        return flagsAndTnf
    }
    
    func toByteArray(messageBegin: Bool, messageEnd: Bool, chunked: Bool) -> [UInt8] {
        let maxShortPayloadLength: Int = 255
        let payloadLength: Int = payload.count
        let typeLength: Int = type.count
        var idLength: Int = 0
        
        var shortRecord: Bool = false
        var idPresent: Bool = false
        
        if payloadLength <= maxShortPayloadLength {
            shortRecord = true
        }
        if id != nil {
            idPresent = true
        }
        
        // Set flags and type name format in first byte of record header.
        let flagsAndTnf = constructFlagsAndTnf(
            messageBegin: messageBegin,
            messageEnd: messageEnd,
            chunked: chunked,
            short: shortRecord,
            idPresent: idPresent
        )
        
        var rawNdefRecord: [UInt8] = [flagsAndTnf]
        
        // Append type length field.
        rawNdefRecord.append(UInt8(typeLength))
        
        // Append payload length field.
        if shortRecord {
            rawNdefRecord.append(UInt8(payloadLength))
        } else {
            let payloadLengthUInt32: UInt32 = UInt32(payloadLength)
            rawNdefRecord.append(UInt8(payloadLengthUInt32 >> 24 & 0xFF))
            rawNdefRecord.append(UInt8(payloadLengthUInt32 >> 16 & 0xFF))
            rawNdefRecord.append(UInt8(payloadLengthUInt32 >> 8 & 0xFF))
            rawNdefRecord.append(UInt8(payloadLengthUInt32 & 0xFF))
        }
        
        // Append id length field.
        if id != nil {
            idLength = id!.count
            rawNdefRecord.append(UInt8(idLength))
        }
        
        // Append the type, id, and payload fields.
        rawNdefRecord.append(contentsOf: type)
        if idLength > 0 {
            rawNdefRecord.append(contentsOf: id!)
        }
        rawNdefRecord.append(contentsOf: payload)
        
        return rawNdefRecord
    }
}
