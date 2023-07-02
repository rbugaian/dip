//
//  SheetView.swift
//  Beamer
//
//  Created by Roman Bugaian on 05.04.23.
//

import Foundation
import SwiftUI

struct P12CertificatePasswordInputView: View {
    @Environment(\.dismiss) var dismiss

    @State var password: String = ""

    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text("Enter password for certificate")
                .bold()
                .padding(.top, 8.0)
                .padding(.bottom, 8.0)

            SecureField("Password", text: $password)
                .padding(.leading, 16.0)
                .padding(.trailing, 16.0)

            HStack {
                Button("Cancel") {
                    logger.debug("Password input cancelled. Clearing pending transaction.")
                    dismiss()
                }
                .padding(.top, 8.0)
                .padding(.leading, 8.0)
                .padding(.trailing, 8.0)
                .padding(.bottom, 8.0)
                
                Button("Confirm") {
                    logger.debug("Password: \(password)")
                    viewModel.pendingP12CertificateTransaction?.certificatePassword = password
                    viewModel.finalizeP12CertificateImport()
                    dismiss()
                }
                .padding(.top, 8.0)
                .padding(.leading, 8.0)
                .padding(.trailing, 8.0)
                .padding(.bottom, 8.0)
            }

        }.frame(width: 300, height: 120)
    }
}

struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        P12CertificatePasswordInputView(viewModel: ViewModel())
    }
}
