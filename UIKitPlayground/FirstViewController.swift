//
//  FirstViewController.swift
//  UIKitPlayground
//
//  Created by 小田島 直樹 on 4/13/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct First {
    @Reducer(state: .equatable)
    enum Destination {
        case navigation(Second)
        case fullScreen(Second)
        case oldView(Third)
    }

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case navigationButtonPressed
        case fullScreenButtonPressed
        case oldButtonPressed
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
            case .oldButtonPressed:
                state.destination = .oldView(.init())
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
            case .destination(.presented(.oldView(.delegate(.buttonPressed)))):
                state.destination = nil
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct FirstScreen: View {
    @Bindable var store: StoreOf<First>
    
    var body: some View {
        VStack {
            Button("Navigation") {
                store.send(.navigationButtonPressed)
            }
            Button("Full Screen") {
                store.send(.fullScreenButtonPressed)
            }
            Button("Old") {
                store.send(.oldButtonPressed)
            }
            Button("Action Sheet") {
                store.send(.actionSheetButtonPressed)
            }
            Button("Alert") {
                store.send(.alertButtonPressed)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { 
            Color.red
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

final class FirstViewController: UIHostingController<FirstScreen> {
    private var destination: First.Destination.CaseScope?
    
    init() {
        super.init(
            rootView: FirstScreen(
                store: .init(initialState: First.State()) {
                    First()._printChanges()
                }
            )
        )
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "First"
        
        observe { [weak self] in
            guard let self else { return }
            
            if let store = rootView.store.scope(state: \.destination, action: \.destination.presented) {
                switch store.case {
                case .navigation(let store):
                    let vc = SecondViewController(store: store)
                    navigationController?.pushViewController(vc, animated: true)
                case .fullScreen(let store):
                    let vc = SecondViewController(store: store)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                case .oldView(let store):
                    let storyboard = UIStoryboard(name: "ThirdViewController", bundle: .main)
                    let vc = storyboard.instantiateInitialViewController { coder in
                        ThirdViewController(coder: coder, store: store)
                    }!
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
                case .oldView:
                    dismiss(animated: true)
                }
                self.destination = nil
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isMovingToParent && rootView.store.destination != nil {
            rootView.store.send(.destination(.dismiss))
        }
    }
}

