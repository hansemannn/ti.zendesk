//
//  TiZendeskModule.swift
//  ti.zendesk
//
//  Created by Hans Knöchel
//  Copyright (c) 2022 Hans Knöchel. All rights reserved.
//

import UIKit
import TitaniumKit
import ZendeskCoreSDK
import SupportSDK

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
    // Verify basic parameters
    guard let params = arguments.first as? [String: Any] else {
      fatalError("Missing required parameters")
    }
    
    // Verify App ID
    guard let appId = params["appId"] as? String else {
      fireEvent("error", with: ["error": "Missing required Zendesk app ID"])
      return
    }
    
    // Verify Client ID
    guard let clientId = params["clientId"] as? String else {
      fireEvent("error", with: ["error": "Missing required Zendesk client ID"])
      return
    }
    
    // Verify Zendesk URL
    guard let url = params["url"] as? String else {
      fireEvent("error", with: ["error": "Missing required Zendesk url"])
      return
    }

    Zendesk.initialize(appId: appId, clientId: clientId, zendeskUrl: url)
    Support.initialize(withZendesk: Zendesk.instance)
    
    fireEvent("ready")
  }
  
  @objc(showMessaging:)
  func showMessaging(arguments: [Any]?) {
    var configurations: [RequestUiConfiguration] = []
    
    // Pass additional (optional) parameters to extend the config
    if let arguments = arguments, let params = arguments.first as? [String: Any] {
      let config = RequestUiConfiguration()
      if let subject = params["subject"] as? String {
        config.subject = subject
      }
      if let tags = params["tags"] as? [String] {
        config.tags = tags
      }
      configurations.append(config)
    }
    
    // Show the support UI
    TiThreadPerformOnMainThread({
      let requestListController = RequestUi.buildRequestList(with: configurations)
      TiApp.controller().topPresentedController().present(requestListController, animated: true)
    }, false)
  }
  
  @objc(loginUser:)
  func loginUser(arguments: [Any]?) {
    guard let arguments = arguments,
          let params = arguments.first as? [String: Any] else {

      Zendesk.instance?.setIdentity(Identity.createAnonymous())

      return
    }
    
    if let jwt = params["jwt"] as? String {
      Zendesk.instance?.setIdentity(Identity.createJwt(token: jwt))
    } else if let name = params["name"] as? String, let email = params["email"] as? String {
      Zendesk.instance?.setIdentity(Identity.createAnonymous(name: name, email: email))
    } else {
      Zendesk.instance?.setIdentity(Identity.createAnonymous())
    }
  }
}
