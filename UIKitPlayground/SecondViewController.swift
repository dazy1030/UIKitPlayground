//
//  SecondViewController.swift
//  UIKitPlayground
//
//  Created by 小田島 直樹 on 4/13/24.
//

import ComposableArchitecture
import SwiftUI
import UIKit

@Reducer
struct Second {
    @ObservableState
    struct State: Equatable {}

    enum Action {
        @CasePathable
        enum View {
            case buttonPressed
        }
        @CasePathable
        enum Delegate {
            case buttonPressed
        }
        
        case view(Action.View)
        case delegate(Action.Delegate)
    }
    
    var body: some ReducerOf<Second> {
        Reduce<State, Action> { state, action in
            switch action {
            case .view(.buttonPressed):
                return .send(.delegate(.buttonPressed))
            case .delegate:
                return .none
            }
        }
    }
}

struct SecondScreen: View {
    var store: StoreOf<Second>
    
    var body: some View {
        Button("Button") {
            store.send(.view(.buttonPressed))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.green
        }
    }
}

final class SecondViewController: UIHostingController<SecondScreen> {
    init(store: StoreOf<Second>) {
        super.init(rootView: SecondScreen(store: store))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second"
    }
}
