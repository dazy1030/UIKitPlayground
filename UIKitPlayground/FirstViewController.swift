//
//  FirstViewController.swift
//  UIKitPlayground
//
//  Created by 小田島 直樹 on 4/13/24.
//

import ComposableArchitecture
import UIKit

@Reducer
struct First {
    @ObservableState
    struct State: Equatable {
        @Presents var second: Second.State?
        @Presents var third: Third.State?
    }
    
    enum Action {
        case secondButtonPressed
        case thirdButtonPressed
        case someViewDismissed
        case second(PresentationAction<Second.Action>)
        case third(PresentationAction<Third.Action>)
    }
    
    var body: some ReducerOf<First> {
        Reduce<State, Action> { (state: inout State, action: Action) in
            switch action {
            case .secondButtonPressed:
                state.second = .init()
                return .none
            case .thirdButtonPressed:
                state.third = .init()
                return .none
            case .someViewDismissed:
                state.second = nil
                state.third = nil
                return .none
            case .second:
                return .none
            case .third:
                return .none
            }
        }
        .ifLet(\.$second, action: \.second) {
            Second()
        }
        .ifLet(\.$third, action: \.third) {
            Third()
        }
    }
}

final class FirstViewController: UIViewController {
    let store: StoreOf<First> = .init(initialState: .init()) {
        First()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "First"
        view.backgroundColor = .red
        
        observe { [weak self] in
            guard let self else { return }
            // Second
            if let store = store.scope(state: \.second, action: \.second.presented) {
                let vc = SecondViewController(store: store)
                navigationController?.pushViewController(vc, animated: true)
            } else {
                navigationController?.popToViewController(self, animated: true)
            }
            // Third
            if let store = store.scope(state: \.third, action: \.third.presented) {
                let vc = ThirdViewController(store: store)
                navigationController?.pushViewController(vc, animated: true)
            } else {
                navigationController?.popToViewController(self, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Handle pop event
        if !isMovingToParent {
            store.send(.someViewDismissed)
        }
    }
    
    @IBAction private func secondButtonPressed(_ sender: Any) {
        store.send(.secondButtonPressed)
    }
    
    @IBAction private func thirdButtonPressed(_ sender: Any) {
        store.send(.thirdButtonPressed)
    }
}

