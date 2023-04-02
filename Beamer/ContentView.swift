//
//  ContentView.swift
//  Beamer
//
//  Created by Roman Bugaian on 06.03.23.
//

import SwiftUI

struct ContentView: View {
    @State var sandboxModeOn: Bool = false
    @State var pushToken: String = ""
    @State var payloadContent: String = ""

    let certificateRepo = CertificateRepository()
    let pushService = PushService()

    var body: some View {
        VStack(alignment: .leading) {
            Picker(selection: .constant(1), label: Text("")) {
                Text("Select Push Certificate").tag(1)
                Text("Select .p12 certificate...").tag(2)
                Text("Select .p8 certificate...").tag(3)
            }
            .padding(.trailing, 8.0)
            .padding(.top, 8.0)

            Toggle(isOn: $sandboxModeOn) {
                Text("Should use sandbox environment.")
            }
            .padding(.leading, 8.0)

            TextField("Device push token", text: $pushToken)
                .padding(.leading, 8.0)
                .padding(.trailing, 8.0)

            HStack {
                Picker(selection: .constant(1), label: Text("")) {
                    Text("Expiry").tag(1)
                    Text("Immediate").tag(2)
                    Text("1 minute").tag(3)
                }.frame(width: 150)

                Picker(selection: .constant(1), label: Text("")) {
                    Text("Priority: None").tag(1)
                    Text("Conserve Power").tag(2)
                    Text("Immediately").tag(3)
                }.frame(width: 150)
                    .padding(.trailing, 8.0)
            }

            TextEditor(text: $payloadContent)
                .padding(.leading, 8.0)
                .padding(.trailing, 8.0)
                .padding(.bottom, 8.0)

            HStack(alignment: .bottom) {
                Spacer()
                Button {
                    Task {
                        let certHelper = CertificateHelper(certificateUrl: Bundle
                            .main
                            .url(
                                forResource: "mobile_apns_tester_cert",
                                withExtension: "p12"
                            )!, password: "Qwertyui92")
                        await certHelper.load()
                        let p12Content = certHelper.pks12Content
                        print("P12: \(p12Content)")
                        
                        let token = "66ae50eb15cf536f31f01005a09f8be4c3b254d7a863ad2e5fa2d6555d170543"
                        await pushService.sendPush(toToken: token, withContent: "{ \"aps\" : { \"alert\" : \"Hello\" } }", authorizedWith: p12Content!)
                    }
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(sandboxModeOn: false)
    }
}
