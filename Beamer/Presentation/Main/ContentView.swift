//
//  ContentView.swift
//  Beamer
//
//  Created by Roman Bugaian on 06.03.23.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    @State var sandboxModeOn: Bool = false
    @State var pushToken: String = ""
    @State var payloadContent: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            CertificateFilePicker(
            )
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
