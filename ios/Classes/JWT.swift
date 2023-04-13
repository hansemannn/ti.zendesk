//
//  JWT.swift
//  TiZendesk
//
//  Created by Hans Knöchel on 12.04.23.
//

import Foundation

import CryptoKit
import Foundation

extension Data {
  func urlSafeBase64EncodedString() -> String {
    return base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

struct Header: Encodable {
  let alg = "HS256"
  let typ = "JWT"
}

struct Payload: Encodable {
  let externalId: String
  let name: String
  let email: String
}

func generateJWT(externalId: String, name: String, email: String) -> String {
  let privateKey = SymmetricKey(data: Data()) // no private key needed here
  
  let headerJSONData = try! JSONEncoder().encode(Header())
  let headerBase64String = headerJSONData.urlSafeBase64EncodedString()
  
  let payloadJSONData = try! JSONEncoder().encode(Payload(externalId: externalId, name: name, email: email))
  let payloadBase64String = payloadJSONData.urlSafeBase64EncodedString()
  
  let toSign = Data((headerBase64String + "." + payloadBase64String).utf8)
  
  let signature = HMAC<SHA256>.authenticationCode(for: toSign, using: privateKey)
  let signatureBase64String = Data(signature).urlSafeBase64EncodedString()
  
  return [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
}
