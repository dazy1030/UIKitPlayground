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
    @Reducer(state: .equatable)
    enum Destination {
        case second(Second)
        case third(Third)
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case secondButtonPressed
        case thirdButtonPressed
        case someViewDismissed
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<First> {
        Reduce<State, Action> { (state: inout State, action: Action) in
            switch action {
            case .secondButtonPressed:
                state.destination = .second(Second.State())
                return .none
            case .thirdButtonPressed:
                state.destination = .third(Third.State())
                return .none
            case .someViewDismissed:
                state.destination = nil
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

final class FirstViewController: UIViewController {
    let store: StoreOf<First> = .init(initialState: .init()) {
        First()
            ._printChanges()
    }
    
    private var destinationVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "First"
        view.backgroundColor = .red
        
        observe { [weak self] in
            guard let self else { return }
            
            if let store = store.scope(state: \.destination, action: \.destination.presented) {
                switch store.case {
                case .second(let store):
                    let vc = SecondViewController(store: store)
                    destinationVC = vc
                    navigationController?.pushViewController(vc, animated: true)
                case .third(let store):
                    let vc = ThirdViewController(store: store)
                    destinationVC = vc
                    navigationController?.pushViewController(vc, animated: true)
                }
            } else if destinationVC is SecondViewController {
                navigationController?.popToViewController(self, animated: true)
                destinationVC = nil
            } else if destinationVC is ThirdViewController {
                // cannot be integrated due to the possibility of modal transitions.
                navigationController?.popToViewController(self, animated: true)
                destinationVC = nil
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Handle pop event
        if !isMovingToParent && store.destination != nil {
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

