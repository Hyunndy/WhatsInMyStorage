//
//  PropertyWrapper.swift
//  WhatsInMyStorage
//
//  Created by hyunndy on 2022/11/01.
//

import Foundation

/*
 @Proxy(\프로퍼티 get, set을 연결하고 싶은 객체의 변수)
 
 https://gist.github.com/jegnux/4a9871220ef93016d92194ecf7ae8919

 EnclsoingSelf란 무엇인가?
 ReferenceWritableKeyPath란 무엇인가?
 */
@propertyWrapper
public struct AnyProxy<EnclosingSelf, Value> {
    
    private let keyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>
    
    public init(_ keyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>) {
        self.keyPath = keyPath
    }
    
    @available(*, unavailable, message: "The wrapped value must be accessed from the enclosing instance property.")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    public static subscript(
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value {
        get {
            let storageValue = observed[keyPath: storageKeyPath]
            let value = observed[keyPath: storageValue.keyPath]
            return value
        }
        set {
            let storageValue = observed[keyPath: storageKeyPath]
            observed[keyPath: storageValue.keyPath] = newValue
        }
    }
}

extension NSObject: ProxyContainer {}
public protocol ProxyContainer {
    typealias Proxy<T> = AnyProxy<Self,T>
}
