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
import ZendeskSDKLogger

@objc(TiZendeskModule)
class TiZendeskModule: TiModule {
  
  func moduleGUID() -> String {
    return "5957ff5a-adde-45f5-aea2-2b887f97f9a9"
  }
  
  override func moduleId() -> String! {
    return "ti.zendesk"
  }

  override func _configure() {
    super._configure()
    TiApp.sharedApp().registerApplicationDelegate(self)
  }
  
  override func _destroy() {
    super._destroy()
    TiApp.sharedApp().unregisterApplicationDelegate(self)
  }

  @objc(initialize:)
  func initialize(arguments: [Any]) {
    // Verify channel key
    guard let params = arguments.first as? [String: Any], let channelKey = params["channelKey"] as? String else {
      fireEvent("error", with: ["error": "Missing required Zendesk channel key"])
      return
    }
    
    if params["logsEnabled"] as? Bool == true {
      Logger.level = .debug
      Logger.enabled = true
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
    
    let jwt = generateJWT(externalId: externalId, name: name, email: email)
    
    Zendesk.instance?.loginUser(with: jwt)
  }
  
  @objc(updateUser:)
  func updateUser(arguments: [Any]?) {
    self.loginUser(arguments: arguments)
  }
  
  @objc(logoutUser:)
  func logoutUser(arguments: [Any]?) {
    Zendesk.instance?.logoutUser()
  }
  
  func convertToData(fromHexString hexString: String) -> Data? {
    let length = hexString.count / 2
    var data = Data(capacity: length)
    for i in 0..<length {
      let start = hexString.index(hexString.startIndex, offsetBy: i*2)
      let end = hexString.index(start, offsetBy: 2)
      let range = start..<end
      if let byte = UInt8(hexString[range], radix: 16) {
        data.append(byte)
      } else {
        return nil
      }
    }
    return data
  }
}

// MARK: UIApplicationDelegate

extension TiZendeskModule: UIApplicationDelegate {
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    PushNotifications.updatePushNotificationToken(deviceToken)
  }
}
