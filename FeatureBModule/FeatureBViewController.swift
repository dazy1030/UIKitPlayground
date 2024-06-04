//
//  FeatureBViewController.swift
//  FeatureBModule
//
//  Created by 小田島 直樹 on 6/4/24.
//

import RxRelay
import SharedModule
import UIKit

public final class FeatureBViewController: UIViewController {
    // Sharedを参照する適当なコード
    public let zero = BehaviorRelay<Int>.zero
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

