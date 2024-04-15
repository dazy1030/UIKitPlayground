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
        case navigation(Second)
        case fullScreen(Second)
    }

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case navigationButtonPressed
        case fullScreenButtonPressed
        case destinationDismissed
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<First> {
        Reduce<State, Action> { state, action in
            switch action {
            case .navigationButtonPressed:
                state.destination = .navigation(.init())
                return .none
            case .fullScreenButtonPressed:
                state.destination = .fullScreen(.init())
                return .none
            case .destinationDismissed:
                state.destination = nil
                return .none
            case .destination(.presented(.navigation(.delegate(let action)))):
                switch action {
                case .buttonPressed:
                    state.destination = nil
                    return .none
                }
            case .destination(.presented(.fullScreen(.delegate(let action)))):
                switch action {
                case .buttonPressed:
                    state.destination = nil
                    return .none
                }
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
    
    private var destination: First.Destination.CaseScope?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "First"
        view.backgroundColor = .red
        
        observe { [weak self] in
            guard let self else { return }
            
            if let store = store.scope(state: \.destination, action: \.destination.presented) {
                switch store.case {
                case .navigation(let store):
                    let vc = SecondViewController(store: store)
                    navigationController?.pushViewController(vc, animated: true)
                case .fullScreen(let store):
                    let vc = SecondViewController(store: store)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
                destination = store.case
            } else if let destination {
                switch destination {
                case .navigation:
                    navigationController?.popToViewController(self, animated: true)
                case .fullScreen:
                    dismiss(animated: true)
                }
                self.destination = nil
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isMovingToParent && store.destination != nil {
            store.send(.destinationDismissed)
        }
    }
    
    @IBAction private func navigationButtonPressed(_ sender: Any) {
        store.send(.navigationButtonPressed)
    }
    
    @IBAction private func fullScreenButtonPressed(_ sender: Any) {
        store.send(.fullScreenButtonPressed)
    }
}

