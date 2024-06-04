//
//  RxUtilities.swift
//  SharedModule
//
//  Created by 小田島 直樹 on 6/4/24.
//

import RxRelay
import RxSwift

public extension Observable<Int> {
    static var zero: Observable<Int> {
        .just(0)
    }
}

public extension BehaviorRelay<Int> {
    static var zero: BehaviorRelay<Int> {
        .init(value: 0)
    }
}
