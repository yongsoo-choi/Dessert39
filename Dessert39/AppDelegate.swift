//
//  AppDelegate.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/09/27.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import NaverThirdPartyLogin
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var networkUtil = NetworkUtil()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter
          .current()
          .requestAuthorization(
            options: authOptions,completionHandler: { (_, _) in }
          )
        application.registerForRemoteNotifications()
        
        // Override point for customization after application launch.
        KakaoSDKCommon.initSDK(appKey: "2b54b9d295e0e233ac3c2ea41dd6128d")

        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        // 네이버 앱으로 인증하는 방식을 활성화
        instance?.isNaverAppOauthEnable = true
        // SafariViewController에서 인증하는 방식을 활성화
        instance?.isInAppOauthEnable = true
        // 인증 화면을 iPhone의 세로 모드에서만 사용하기
        instance?.isOnlyPortraitSupportedInIphone()

        // 네이버 아이디로 로그인하기 설정
        // 애플리케이션을 등록할 때 입력한 URL Scheme
        instance?.serviceUrlScheme = "naverlogin"
        // 애플리케이션 등록 후 발급받은 클라이언트 아이디
        instance?.consumerKey = "gonQ_zmB9NTtNfXpEIi_"
        // 애플리케이션 등록 후 발급받은 클라이언트 시크릿
        instance?.consumerSecret = "bToV9pVN9W"
        // 애플리케이션 이름
        instance?.appName = "dessert39"
        
//        UserDefaults.standard.set(0, forKey: "badgeNum")
//        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if #available(iOS 13.0, *) {
            //
        } else {
            Switcher.updateRootVC()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         Messaging.messaging().apnsToken = deviceToken
//        store.alarmBageCheck(chk: true)
      }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        NaverThirdPartyLoginConnection.getSharedInstance()?.application(app, open: url, options: options)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
//        let userInfo = notification.request.content.userInfo
//        let identifier = notification.request.identifier
//        print("userInfo : ", userInfo)
//        print("identifier : ", identifier)
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        completionHandler([.banner, .sound])
        
        if let tbc = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController as? UITabBarController {
            
            store.alarmBage = true
            tbc.tabBar.items![1].badgeValue = "●"
            tbc.tabBar.items![1].badgeColor = .clear
            tbc.tabBar.items![1].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
            
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        completionHandler()
        
        if let tbc = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController as? UITabBarController {
            
            store.alarmBage = true
            tbc.tabBar.items![1].badgeValue = "●"
            tbc.tabBar.items![1].badgeColor = .clear
            tbc.tabBar.items![1].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
            
        }
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")
        store.fcmToken = fcmToken!
    }
    
}


