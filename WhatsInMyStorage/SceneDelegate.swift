//
//  SceneDelegate.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/10/31.
//

import UIKit

/*
 Scene/Window에 무엇을 보여줄지 관리하는 역할을 한다.
 
 UIScreen
    - UIWindowScene
        - UIWindow
            - UIView
            - UIView
 
    - UIWindowScene
        - UIWindow
            - UIView
            - UIView
            - UIView
 
 UIWindowScene이란?
    - UIScene의 서브 클래스로, App의 하나 이상의 Window를 관리한다.
    - 직접 생성하면 안되고, configuration Time에 원하는 UIWindowScene에 대해 명시하라고 한다. -> info.plistdml scene configuration details
 
 UISceneSession
    - App의 Scene들 중 하나의 Scene에 대한 정보를 갖고 있는 객체
    - 내부에 Scene: UIScene? 옵셔널 변수를 갖고, connect/disconnect 시킨다.
 
 UIWindow
    - App의 UI에 대한 배경과 Event를 View에 전달하는 객체
    - App의 컨텐츠를 표기할 기본 Window 제공
    - 추가 컨텐츠를 표기할 때, 필요한 경우 추가 Window를 생성한다.
 
 결론
    - UIWindowScene 객체를 이용하여 앱의 UI를 관리한다.
    - Scene은 여러개의 Window들과 VC들을 포함하며 하나의 UI 인스턴스를 표현한다.
    - 각 Scene은 UIWindowSceneDelegate 객체를 갖고 있다. (각 Scene memory를 동기화한다.)
 */
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    /*
     UISceneSession lifeCycle에서 제일 처음 불리는 메서드.
     첫 contentView인 UIWindow를 생성하고, window의 rootViewController를 설정합니다.
     
     이 때 헷갈리지 않아야할 점은...
     이 'window'가 사용자가 보는 window가 아니라 app이 작동하는 viewPort라는 것.
     
     첫 view를 만들 때도 쓰이지만, 과거에 disconnected된 UI를 되돌릴 때도 쓰입니다.
     
     코드로 UI를 짜려고 스토리보드를 해제했다면, 여기서 setUp하면 된다.
     
     멀티 윈도우를 지원하기 때문에, UIWindowScene을 생성하면, UISceneSession으로 willConnect 되는 것이다!
     */
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        /*
         UIScreen
            - UIWindowScene
                - UIWindow
                    - UIView
                    - UIView
         */
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let mainViewController = ViewController()
        
        self.window?.rootViewController = mainViewController
        self.window?.makeKeyAndVisible()
    }
    
    /*
     위 과정이 끝나면 다음 불리는 메서드.
     
     scene이 foreground로 전환될 때 불립니다.
        1) background -> foreground가 되었을 때.
        2) 처음 active 되었을 때.
     */
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    /*
     1) 처음 Active 되었을 때 Scene이 SetUp되고 화면에 보여지면서 사용 될 준비가 완료 된 상태.
     2) inActive -> active로 전환할 때
     
     inActive 상태가 되어서 멈췄던 task를 재실행할 수도 있고, 처음 불렸다면 그냥 사용하면 된다!
     */
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    /*
     active -> inActive 상태로 빠질 때 불리는 메서드.
     사용 중 전화가 걸려오는 것 처럼 임시 interruption 때문에 발생할 수 있다.
     */
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    /*
     scene이 foreground -> background 상태가 될 때 불리므로 다시 foreground로 돌아올 때 복원할 수 있도록
        - state 정보를 저장하거나,
        - 데이터를 저장하거나,
        - 공유 자원을 돌려주는 등
     의 작업을 하면 된다.
     */
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    /*
     Scene이 Background로 들어갔을 때 시스템이 자원을 확보하기 위해 disconnect하려고 할 수도 있습니다.
     (disconnect와 app 종료는 다른 의미입니다. scene이 이 메서드로 전달되면 session에서 끊어진다는 것 뿐입니다.)
     
     이 메서드에서 해야할 가장 중요한 작업은 필요없는 자원을 돌려주는 것 입니다.
        - 디스크나 네트워크를 통해 쉽게 불러올 수 있거나 생성이 쉬운 데이터는 돌려주고
        - 사용자의 input과 같이 재생성이 어려운 데이터는 갖고 있게끔 하는 작업을 해주어야 한다.
     
     */
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }








}

