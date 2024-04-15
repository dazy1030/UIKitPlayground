//
//  ThirdViewController.swift
//  UIKitPlayground
//
//  Created by 小田島 直樹 on 4/15/24.
//

import ComposableArchitecture
import UIKit

protocol ThirdViewControllerDelegate: AnyObject {
    func thirdViewControllerDidButtonPress(_ viewController: ThirdViewController)
}

@Reducer
struct ThirdDelegate {
    enum Action {
        case buttonPressed
    }
}

final class ThirdViewController: UIViewController {
    let store: StoreOf<ThirdDelegate>?
    weak var delegate: ThirdViewControllerDelegate?
    
    required init?(coder: NSCoder, store: StoreOf<ThirdDelegate>? = nil) {
        self.store = store
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Third"
    }
    
    @IBAction private func buttonPressed(_ sender: Any) {
        delegate?.thirdViewControllerDidButtonPress(self)
        store?.send(.buttonPressed)
    }
}
