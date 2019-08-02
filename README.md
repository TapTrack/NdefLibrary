# NdefLibrary

[![Version](https://img.shields.io/cocoapods/v/NdefLibrary.svg?style=flat)](https://cocoapods.org/pods/NdefLibrary)
[![License](https://img.shields.io/cocoapods/l/NdefLibrary.svg?style=flat)](https://github.com/angular/angular.js/blob/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/NdefLibrary.svg?style=flat)](https://cocoapods.org/pods/NdefLibrary)

## Description

This library is intended for use in applications that use external NFC readers (such as TapTrack Tappy 
readers) from which NDEF messages must be validated, parsed, and composed.

This library supports NDEF messages with the following record types:

* Text records
* URI records
* Custom NDEF records

## Installation

NdefLibrary is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

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

If you are familiar with the payload syntax of text records, you can also specify the payload directly.

```Swift
let statusByte : [UInt8] = [0x02] // UTF-8 encoding, lanaguage code length 2
let languageCode : [UInt8] = [0x6E, 0x68] // "en"
let helloWorldText : [UInt8] = [0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21]

// A text record payload is composed of a status byte, the language code, and the encoded text.
let helloWorldPayload : [UInt8] = statusByte + languageCode + helloWorldText

// Construct the text record.
let textRecord = Ndef.CreateTextRecord(payload: helloWorldPayload)
```

#### URI Records

You can create a URI record by specifying the URI string.

```Swift
let githubUrl = "https://www.github.com/"

// Construct the URI record.
let uriRecord = Ndef.CreateUriRecord(uri: githubUrl)
```

You can also specify the payload directly. Note that the first byte of the payload must describe the protocol prefix field of the URI. To indicate that there is no prefixing, use code ```0x00```.

```Swift
let prefixProtocol : [UInt8] = [0x02] // This is the protocol for the "https://www." prefix.
let githubUrl : [UInt8] = [0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2E, 0x63, 0x6F, 0x6D] // "github.com"

// A URI record payload is composed of a prefix protocol, followed by the encoded URL.
let githubUrlPayload : [UInt8] = prefixProtocol + githubUrl

// Construct the URI record.
let uriRecord = Ndef.CreateUriRecord(payload: githubUrlPayload)
```

#### Custom Records

To create a record of any other type, you can use the ```GenericRecord``` object.

```Swift
let wellKnownTnf = Ndef.TypeNameFormat.wellKnown
let recordType : [UInt8] = [0x74, 0x65, 0x73, 0x74]
let recordPayload : [UInt8] = [0x63, 0x75, 0x73, 0x74, 0x6f, 0x6d]

// Construct a custom NDEF record.
let customRecord = Ndef.CreateGenericRecord(tnf: wellKnownTnf, type: recordType, payload: recordPayload)
```

#### Optional Return Values

Note that some of the record constructing methods will return optional values that must be unwrapped before use.

### Creating Messages

You can construct an NDEF message by specifying an array of records.

```Swift
let myRecords : [NdefRecord] = [record1, record2, record3];

// Construct an NDEF message.
let message = Ndef.CreateNdefMessage(records: myRecords)
```

### Parsing Messages

You can parse NDEF messages by passing the raw byte array to the ```CreateNdefMessage(rawByteArray: [UInt8])``` method. It will return an ```NdefMessage``` object that contains an array of NDEF records, which you can access though the ```records``` field.

*Note: Chunked records are not currently supported. The ```CreateNdefMessage``` method will return ```nil``` if it encounters a record with the chunked flag set.*

```Swift
// Construct an NdefMessage from a raw byte array. If the raw byte array does
// not represent a valid, complete NDEF message, this method will return nil.
let message = Ndef.CreateNdefMessage(rawByteArray: rawMessage)

// Unwrap the message and get the array of records.
var records : [NdefRecord] = []
if let unwrappedMsg = message {
records = unwrappedMsg.records
}
```

You can then access the fields of each record.

```Swift
// Print out the tnf, type, and payload of each record in the NDEF message.
for record in records {
let typeNameFormat = record.tnf
let type = record.type
let payload = record.payload
}
```

To access record-specific fields, you will need to downcast.

```Swift
// Get the contents of a record by downcasting it as a TextRecord.
if let textRecord = records[0] as? TextRecord {
let encoding = textRecord.textEncoding
let language = textRecord.languageCode
let text = textRecord.text
}

// Get the contents of a record by downcasting it as a UriRecord.
if let uriRecord = records[1] as? UriRecord {
let uriString = uriRecord.uri
}
```

## Author

Alice Cai, info@taptrack.com

## License

NdefLibrary is available under the MIT license. See the LICENSE file for more info.
