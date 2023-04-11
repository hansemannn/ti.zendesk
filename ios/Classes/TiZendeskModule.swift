//
//  TiZendeskModule.swift
//  ti.zendesk
//
//  Created by Hans Knöchel
//  Copyright (c) 2023 Hans Knöchel. All rights reserved.
//

import UIKit
import TitaniumKit

import ZendeskSDKMessaging
import ZendeskSDK

@objc(TiZendeskModule)
class TiZendeskModule: TiModule {
  
  func moduleGUID() -> String {
    return "5957ff5a-adde-45f5-aea2-2b887f97f9a9"
  }
  
  override func moduleId() -> String! {
    return "ti.zendesk"
  }
  
  @objc(initialize:)
  func initialize(arguments: [Any]) {
    // Verify channel key
    guard let params = arguments.first as? [String: Any], let channelKey = params["channelKey"] as? String else {
      fireEvent("error", with: ["error": "Missing required Zendesk channel key"])
      return
    }

    Zendesk.initialize(withChannelKey: channelKey, messagingFactory: DefaultMessagingFactory()) { result in
      if case let .failure(error) = result {
        print("Messaging did not initialize.\nError: \(error.localizedDescription)")
        return
      }
    }

    fireEvent("ready")
  }
  
  @objc(showMessaging:)
  func showMessaging(arguments: [Any]?) {
    guard let viewController = Zendesk.instance?.messaging?.messagingViewController() else {
      return
    }

    TiApp.controller().topPresentedController().show(viewController, sender: self)
  }
  
  @objc(loginUser:)
  func loginUser(arguments: [Any]?) {
    guard let arguments = arguments,
          let params = arguments.first as? [String: Any],
          let externalId = params["externalId"] as? String,
          let name = params["name"] as? String,
          let email = params["email"] as? String else {
            
      return
    }
    
    let jwt = "" // TODO: Generate JWT from external ID, name and email (via "payload" field)
    
    Zendesk.instance?.loginUser(with: jwt)
  }
  
  @objc(updateUser:)
  func updateUser(arguments: [Any]?) {
    self.loginUser(arguments: arguments)
  }
  
  @objc(logout:)
  func logout(arguments: [Any]?) {
    Zendesk.instance?.logoutUser()
  }
}
