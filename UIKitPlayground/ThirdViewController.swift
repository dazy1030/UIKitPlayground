//
//  ThirdViewController.swift
//  UIKitPlayground
//
//  Created by 小田島 直樹 on 4/13/24.
//

import ComposableArchitecture
import UIKit

@Reducer
struct Third {}

final class ThirdViewController: UIViewController {
    let store: StoreOf<Third>
    
    init(store: StoreOf<Third>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Third"
        view.backgroundColor = .blue
    }
}
