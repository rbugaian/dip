//
//  FilePicker.swift
//  Beamer
//
//  Created by Pavel BUGAIAN on 16.03.2023.
//
import SwiftUI

enum CertificateFileFormat: String, CaseIterable, Identifiable {
    case p8, p12
    var id: Self { self }
}

class File {
}

class FilePicker {
    func pickFile(format: CertificateFileFormat) {
        print("File picked")
    }
}

extension EnvironmentValues {
    var filePicker: FilePicker {
        get { self[FilePickerKey.self] }
        set { self[FilePickerKey.self] = newValue }
    }
}

private struct FilePickerKey: EnvironmentKey {
    static let defaultValue: FilePicker = FilePicker()
}
