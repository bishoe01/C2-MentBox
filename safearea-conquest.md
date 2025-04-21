# iOS SafeArea 정복기: 화면 전체를 내 맘대로!

## 문제 상황
iOS 앱을 개발하다 보면, 특히 iPhone X 이후의 기기에서는 상단 노치와 하단 홈 인디케이터, 그리고 양옆의 베젤 부분이 safeArea로 지정되어 있어서 컨텐츠가 이 영역을 침범하지 못하는 문제가 있습니다. 우리는 이 safeArea를 완전히 무시하고 화면 전체를 자유롭게 사용하고 싶었습니다.

## 시도 1: 기본적인 ignoresSafeArea
```swift
ZStack {
    Image("BG")
        .resizable()
        .ignoresSafeArea()
}
```
이 방법은 간단하지만, 완전한 해결책이 되지 못했습니다. 특히 양옆의 safeArea는 여전히 존중되었습니다.

## 시도 2: NavigationView 구조 분석
앱의 구조를 분석해보니 중첩된 NavigationView가 문제를 일으키고 있었습니다:
```
MentBoxApp
└── NavigationView
    └── SignInView
        └── ContentView
            └── TabView
                └── HomeView
                    └── NavigationView (중복!)
```
이런 중첩 구조는 safeArea 무시를 방해하고 있었습니다.

## 해결책: 구조 단순화와 적절한 설정

### 1. NavigationView 구조 단순화
```swift
// MentBoxApp.swift
@main
struct MentBoxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea(.all)
        }
    }
}
```

### 2. UIWindow 설정
```swift
init() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        if let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = .dark
            let controller = UIHostingController(rootView: AnyView(EmptyView()))
            controller.view.backgroundColor = .clear
            window.rootViewController = controller
        }
    }
}
```

### 3. View 계층 구조 최적화
```swift
struct ContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView()
                StarsView()
                MyLetterView()
            }
            .ignoresSafeArea(.all)
            
            CustomTabBar()
        }
        .ignoresSafeArea(.all)
    }
}
```

## 핵심 포인트

1. **중첩된 NavigationView 제거**
   - 불필요한 NavigationView 중첩을 제거하여 safeArea 무시를 방해하는 요소를 제거했습니다.

2. **UIWindow 설정**
   - `UIHostingController`를 사용하여 window의 rootViewController를 설정했습니다.
   - 이를 통해 시스템 레벨에서 safeArea 무시가 가능해졌습니다.

3. **일관된 ignoresSafeArea 적용**
   - 모든 주요 View에 `.ignoresSafeArea(.all)`을 적용하여 일관된 safeArea 무시를 구현했습니다.

## 결과
이러한 변경을 통해:
- 상단 노치 영역
- 하단 홈 인디케이터 영역
- 양옆 베젤 영역
모두를 자유롭게 사용할 수 있게 되었습니다!

## 추가 팁
만약 여전히 문제가 있다면, Info.plist에 다음 설정을 추가해보세요:
```xml
<key>UIRequiresFullScreen</key>
<true/>
<key>UIViewControllerBasedStatusBarAppearance</key>
<false/>
```

## 결론
iOS의 safeArea를 완전히 정복하기 위해서는:
1. View 계층 구조의 단순화
2. 시스템 레벨 설정
3. 일관된 safeArea 무시 적용
이 세 가지가 모두 필요했습니다. 이제 당신의 앱도 화면 전체를 자유롭게 사용할 수 있습니다! 
