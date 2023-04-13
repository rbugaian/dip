//
//  FilePicker.swift
//  Beamer
//
//  Created by Pavel BUGAIAN on 16.03.2023.
//

import ComposableArchitecture
import SwiftUI

enum FilePickerState: String, CaseIterable, Identifiable {
    case leading = "Select Push Certificate"

    case p8 = "Select .p8 certificate..."

    case p12 = "Select .p12 certificate..."

    var id: Self { self }
}

struct CertificateFilePicker: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { _ in
            ProgressView()

//            if viewStore.loadingState.isLoading {
//                ProgressView()
//            } else {
//                Picker("", selection: viewStore.binding(get: \.filePickerState, send: ViewAction.formatSelected)) {
//                    ForEach(FilePickerState.allCases) { state in
//                        Text(state.rawValue)
//                    }
//                }
//            }
        }
    }
}

// extension CertificateFilePicker {
//    struct ViewState: Equatable {
//        let filePickerState: FilePickerState
//
//        let loadingState: LoadingState
//    }
// }
//
// extension CertificateFilePicker.ViewState {
//    enum LoadingState: Equatable {
//        case loaded(fileFormat: FilePickerState)
//
//        case loading
//
//        var fileFormat: FilePickerState {
//            guard case let .loaded(fileFormat) = self else { return .leading }
//
//            return fileFormat
//        }
//
//        var isLoading: Bool { self == .loading }
//    }
// }
//
// extension CertificateFilePicker {
//    enum ViewAction: Equatable {
//        case formatSelected(FilePickerState)
//    }
// }
//
// struct CertificateFilePickerState: Equatable {
//    var filePickerState: FilePickerState
//
//    var fileName: String?
//
//    static let initial = CertificateFilePickerState(filePickerState: .leading)
// }
//
// enum CertificateFilePickerAction: Equatable {
//    case selectFormat
//
//    case selectFormatDone(FilePickerState)
// }
//
// struct CertificateFilePickerEnvironment {
//    var loadFile: () -> Effect<String, Never>
// }
//
// extension CertificateFilePickerState {
//    static let reducer = Reducer<CertificateFilePickerState, CertificateFilePickerAction, CertificateFilePickerEnvironment> { state, action, _ in
//        switch action {
//        case .selectFormat:
//            return .none
//
//        case let .selectFormatDone(formatState):
//            state.filePickerState = formatState
//            return .none
//        }
//    }
// }
