//
//  ViewController.swift
//  UIKitPlayground
//
//  Created by 小田島 直樹 on 4/13/24.
//

import FeatureAModule
import FeatureBModule
import RxRelay
import RxSwift
import SharedModule
import UIKit

final class ViewController: UIViewController {
    // Feature, Sharedを参照する適当なコード
    let featureAVC = FeatureAViewController()
    let featureBVC = FeatureBViewController()
    let observableZero = Observable<Int>.zero
    let relayZero = BehaviorRelay<Int>.zero

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
