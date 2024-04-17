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
struct Third {
    @ObservableState
    struct State: Equatable {}
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case buttonPressed
        }
        
        @CasePathable
        enum DelegateAction {
            case buttonPressed
        }
        
        case view(ViewAction)
        case delegate(DelegateAction)
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .buttonPressed:
                    return .send(.delegate(.buttonPressed))
                }
            case .delegate:
                return .none
            }
        }
    }
}

final class ThirdViewController: UIViewController {
    let store: StoreOf<Third>?
    weak var delegate: ThirdViewControllerDelegate?
    
    required init?(coder: NSCoder, store: StoreOf<Third>? = nil) {
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
        store?.send(.view(.buttonPressed))
    }
}
