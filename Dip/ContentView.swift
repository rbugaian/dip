//
//  ContentView.swift
//  Beamer
//
//  Created by Roman Bugaian on 06.03.23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()

    @State private var isSandbox = true

    @State var certSelection = 1

    var body: some View {
        VStack(alignment: .leading) {
            Picker(selection: $viewModel.certificateSelection, label: Text("")) {
                ForEach(viewModel.certificatePickerItems) { item in
                    Text(item.text).tag(item.id)
                }
            }
            .padding(.trailing, 8.0)
            .padding(.top, 8.0)
            .onChange(of: viewModel.certificateSelection) { newValue in
                viewModel.handlePickerSelection(newValue)
            }

            if viewModel.p8CredentialsRequired {
                TextField("Key ID", text: $viewModel.keyId)
                    .padding(.leading, 8.0)
                    .padding(.trailing, 8.0)

                TextField("Team ID", text: $viewModel.teamId)
                    .padding(.leading, 8.0)
                    .padding(.trailing, 8.0)
            }

            Toggle(isOn: $viewModel.sandboxModeOn) {
                Text("Should use sandbox environment.")
            }
            .padding(.leading, 8.0)

            TextField("Bundle ID (e.g. com.example.app)", text: $viewModel.bundleId)
                .padding(.leading, 8.0)
                .padding(.trailing, 8.0)

            TextField("Device push token", text: $viewModel.token)
                .padding(.leading, 8.0)
                .padding(.trailing, 8.0)

            HStack {
                Picker(selection: $viewModel.selectedExpiry, label: Text("")) {
                    Text("Expiry").tag(1)
                    Text("Immediate").tag(2)
                    Text("1 minute").tag(3)
                }.frame(width: 150)

                Picker(selection: $viewModel.selectedPriority, label: Text("")) {
                    Text("Priority").tag(1)
                    Text("None (1)").tag(2)
                    Text("Conserve Power (5)").tag(3)
                    Text("Immediately (10)").tag(4)
                }.frame(width: 150)
                    .padding(.trailing, 8.0)
            }

            TextEditor(text: $viewModel.payload)
                .padding(.leading, 8.0)
                .padding(.trailing, 8.0)
                .padding(.bottom, 8.0)
                .disableAutocorrection(true)
                .font(.body)
                .monospaced()

            HStack(alignment: .bottom) {
                if $viewModel.statusTextVisible.wrappedValue {
                    Text(viewModel.statusText)
                        .foregroundColor(viewModel.statusColor)
                        .padding(.bottom, 10.0)
                        .padding(.leading, 10.0)
                } else {
                    Text(viewModel.statusText)
                        .foregroundColor(viewModel.statusColor)
                        .padding(.bottom, 10.0)
                        .padding(.leading, 10.0)
                        .hidden()
                }
                
                Spacer()
                Button {
                    viewModel.sendPush()
                } label: {
                    Text("Send")
                }
                .padding(.trailing, 8.0)
                .padding(.bottom, 8.0)
            }
        }
        .padding(4.0)
        .frame(minWidth: 600, minHeight: 300)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $viewModel.passwordSheetShown) {
            logger.debug("Sheet dismissed!")
        } content: {
            P12CertificatePasswordInputView(viewModel: viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension NSTextView {
    override open var frame: CGRect {
        didSet {
            isAutomaticQuoteSubstitutionEnabled = false
        }
    }
}
