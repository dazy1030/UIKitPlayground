//
//  SecondViewController.swift
//  UIKitPlayground
//
//  Created by 小田島 直樹 on 4/13/24.
//

import ComposableArchitecture
import UIKit

@Reducer
struct Second {}

final class SecondViewController: UIViewController {
    let store: StoreOf<Second>
    
    init(store: StoreOf<Second>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second"
        view.backgroundColor = .yellow
    }
}
