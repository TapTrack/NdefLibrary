# NdefLibrary

[![Version](https://img.shields.io/cocoapods/v/NdefLibrary.svg?style=flat)](https://cocoapods.org/pods/NdefLibrary)
[![License](https://img.shields.io/cocoapods/l/NdefLibrary.svg?style=flat)](https://github.com/angular/angular.js/blob/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/NdefLibrary.svg?style=flat)](https://cocoapods.org/pods/NdefLibrary)

## Description

NFC Data Exchange format (NDEF) specifies a common data format for NFC Forum-compliant devices and NFC Forum-compliant tags. Version 1.0 of this specification can be found [here](http://sweet.ua.pt/andre.zuquete/Aulas/IRFID/11-12/docs/NFC%20Data%20Exchange%20Format%20(NDEF).pdf).<sup>[1]</sup>

This library is intended for use in applications that use external NFC readers (such as TapTrack Tappy 
readers) from which NDEF messages must be validated, parsed, and composed.

This library supports NDEF messages with the following record types:

* Text records
* URI records
* Generic records

## Installation Using CocoaPods

```ruby
pod 'NdefLibrary'
```

## How to Use

### Creating Records

#### Text Records

You can create a text record by specifying the text encoding type, the language code, and the text.

```Swift
let encoding = TextRecord.TextEncodingType.Utf8
let languageCode : String = "en"
let text : String = "hello world!"

// Construct the text record.
let textRecord = Ndef.CreateTextRecord(textEncoding: encoding, languageCode: languageCode, text: text)
```

You can create a TextRecord from a raw byte array by passing it to the ```CreateNdefMessage``` method (see [Parsing Messages](#parsing-raw-ndef-messages) below).

#### URI Records

You can create a URI record by specifying the URI string.

```Swift
let githubUrl = "https://www.github.com/"

// Construct the URI record.
let uriRecord = Ndef.CreateUriRecord(uri: githubUrl)
```

You can create a UriRecord from a raw byte array by passing it to the ```CreateNdefMessage``` method (see [Parsing Messages](#parsing-raw-ndef-messages) below).

#### Generic Records

To create a record of any other type, you can use the ```GenericRecord``` object. You will need to specify the Type Name Format, the record type, and the payload.

```Swift
let tnf = Ndef.TypeNameFormat.external
let recordType : [UInt8] = [0x74, 0x65, 0x73, 0x74]
let recordPayload : [UInt8] = [0x63, 0x75, 0x73, 0x74, 0x6f, 0x6d]

// Construct a custom NDEF record. This method will return nil if the payload is invalid.
let customRecord = Ndef.CreateGenericRecord(tnf: tnf, type: recordType, payload: recordPayload)
```

### Creating NDEF Messages

You can construct an NDEF message by specifying an array of records.

```Swift
let myRecords : [NdefRecord] = [record1, record2, record3]

// Construct an NDEF message.
let message = Ndef.CreateNdefMessage(records: myRecords)
```

You can also convert the ```NdefMessage``` object into a raw byte array by calling the ```toByteArray()``` instance method.

```Swift
let rawMessage = message.toByteArray()
```

### Parsing Raw NDEF Messages

You can parse raw NDEF messages by passing the raw byte array to the ```CreateNdefMessage(rawByteArray: [UInt8])``` method. It will return an ```NdefMessage``` object that contains an array of NDEF records, which you can access though the ```records``` field.

*Note: Chunked records are not currently supported. The ```CreateNdefMessage``` method will return ```nil``` if it encounters a record with the chunked flag set.*

```Swift
// Empty NDEF record for example purposes.
let rawNdefMessage : [UInt8] = [0xD0, 0x00, 0x00]

// Construct an NdefMessage from a raw byte array. If the raw byte array does
// not represent a valid, complete NDEF message, this method will return nil.
let message = Ndef.CreateNdefMessage(rawByteArray: rawNdefMessage)

// Unwrap the message and get the array of records.
var records : [NdefRecord] = []
if let unwrappedMsg = message {
    records = unwrappedMsg.records
}
```

You can then access the fields of each record.

```Swift
// Print out the TNF, type, and payload of each record in the NDEF message.
for record in records {
    print("Type Name Format: \(record.tnf)")
    print("Type: \(record.type)")
    print("Payload: \(record.payload)")
}
```

To access record-specific fields, you will need to downcast.

```Swift
// Get the contents of a TextRecord by downcasting.
if let textRecord = records[0] as? TextRecord {
    let encoding = textRecord.textEncoding
    let language = textRecord.languageCode
    let text = textRecord.text
}

// Get the contents of a UriRecord by downcasting.
if let uriRecord = records[1] as? UriRecord {
    let uriString = uriRecord.uri
}
```

### Optional Return Values

Note that some of the record constructing methods will return optional values that must be unwrapped before use. See below for examples of unwrapping. You can also refer to the [official Swift documentation](https://docs.swift.org/swift-book/LanguageGuide/OptionalChaining.html) for a more detailed explanation.

## Contributors

Author: [Alice Cai](https://github.com/alice-cai)

Library maintained by TapTrack (info@taptrack.com).

## License

NdefLibrary is available under the MIT license. See the LICENSE file for more info.

## Footnotes

<sup>[1]</sup> This link may not persist because the NFC Forum has limited access to its specifications to paying members and may force this page to be removed in the future.
