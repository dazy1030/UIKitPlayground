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
        case actionSheet(ConfirmationDialogState<ActionSheetAction>)
        case alert(AlertState<AlertAction>)
    }
    
    @CasePathable
    enum ActionSheetAction {
        case dismiss
    }
    
    @CasePathable
    enum AlertAction {
        case dismiss
    }

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case navigationButtonPressed
        case fullScreenButtonPressed
        case oldButtonPressed
        case actionSheetButtonPressed
        case alertButtonPressed
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
            case .actionSheetButtonPressed:
                state.destination = .actionSheet(
                    ConfirmationDialogState<ActionSheetAction>(
                        titleVisibility: .visible,
                        title: { TextState("タイトル")},
                        actions: {
                            ButtonState(action: .dismiss) {
                                TextState("閉じる")
                            }
                            ButtonState(role: .cancel) {
                                TextState("キャンセル")
                            }
                        },
                        message: {
                            TextState("メッセージ")
                        }
                    )
                )
                return .none
            case .alertButtonPressed:
                state.destination = .alert(
                    AlertState<AlertAction>(
                        title: {
                            TextState("Title")
                        },
                        actions: {
                            ButtonState(action: .dismiss) {
                                TextState("Dismiss")
                            }
                            ButtonState(role: .cancel) {
                                TextState("Cancel")
                            }
                        },
                        message: {
                            TextState("Message")
                        }
                    )
                )
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
            case .destination(.presented(.actionSheet(.dismiss))):
                state.destination = nil
                return .none
            case .destination(.presented(.alert(.dismiss))):
                state.destination = nil
                return .none
            case .destination(.dismiss):
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
        .confirmationDialog($store.scope(state: \.destination?.actionSheet, action: \.destination.actionSheet))
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
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
                default:
                    break
                }
                destination = store.case
            } else if let destination {
                switch destination {
                case .navigation:
                    navigationController?.popToViewController(self, animated: true)
                case .fullScreen, .oldView:
                    dismiss(animated: true)
                default:
                    break
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

