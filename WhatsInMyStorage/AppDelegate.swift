//
//  AppDelegate.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/10/31.
//

import UIKit

/*
 * AppDelegate.swift의 역할
    - App의 entry Point
    - application level의 life-cycle을 관리하는 역할

 * App의 entry Point
    - Swift 프로젝트에는 왜 C++ 프로젝트 처럼 Main 함수가 없는걸까?
        -> UIKit 프레임워크에 숨어있기 떄문이다.
 
    - Swift 컴파일러는 @main 어노테이션을 통해 AppDelegate에서 전역범위에 있는 코드를 자동으로 인식하게 하고 실행시켜 Entry Point가 되게 한다.
 
 
 * AppDelegate Class는 UIApplicationDelegate를 채택하며, 이 프로토콜은
    - 앱 세팅
    - 앱 상태 변화에 응답하며 다른 app-level 이벤트를 처리하는데 사용하는 여러가지 방법을 정의합니다.
 
 * iOS13 이후 부터는 Window 관리를 SceneDelegate에 위임합니다. 여러개의 Window를 사용할 수 있고, 여러개의 Scene을 사용할 수 있습니다.
 그렇다면 window와 scene의 차이점은 무엇일까? sceneDelegate에 설명한다.
 */
@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    /*
     Application Setup.
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    /*
     Application이 새로운 Scene/Window를 제공하려고 할 때 불린다. (최초 launch 아님)
     */
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /*
     Scene을 버릴 때 불린다. 버리는 상황이란 swipe로 멀티 윈도우를 없앤다던지, 코드로서 없애는 경우이다.
     */
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

