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
                logger.debug("PickerChanged: \(newValue)")
                switch newValue {
                case -2: viewModel.startP12CertificateImport()
                case -3: viewModel.importP8Certificate()
                default: break // do nothing
                }
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
                .disableAutocorrection(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .font(/*@START_MENU_TOKEN@*/ .body/*@END_MENU_TOKEN@*/)
                .monospaced()

            HStack(alignment: .bottom) {
                Spacer()
                Button {
                    viewModel.sendPush()
//                    Task {
//                        let certHelper = CertificateHelper(certificateUrl: Bundle
//                            .main
//                            .url(
//                                forResource: "mobile_apns_tester_cert",
//                                withExtension: "p12"
//                            )!, password: "Qwertyui92")
//                        await certHelper.load()
//                        let p12Content = certHelper.pks12Content
//                        print("P12: \(p12Content)")
//
//                        let token = "66ae50eb15cf536f31f01005a09f8be4c3b254d7a863ad2e5fa2d6555d170543"
//                        await pushService.sendPush(toToken: token, withContent: "{ \"aps\" : { \"alert\" : \"Hello\" } }", authorizedWith: p12Content!)
//                    }
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
