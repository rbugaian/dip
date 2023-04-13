//
//  FilePickerReducer.swift
//  Beamer
//
//  Created by Pavel BUGAIAN on 31.03.2023.
//

import ComposableArchitecture
import Foundation
import SwiftUI

class FilePickerAction: AppAction {
    struct Start: Equatable {
    }

    struct Success: Equatable {
    }

    struct Error: Equatable {
    }
}

class FilePickerReducer: BaseReducer {
    @Environment(\.filePicker) var filePicker: FilePicker

    func reduce(into state: inout AppState, action: AppAction) -> EffectTask<AppAction> {
        
        return .none
    }
}

protocol BaseReducer: ReducerProtocol where State == AppState, Action == AppAction {
    func reduce(into state: inout AppState, action: AppAction) -> EffectTask<Action>
}
