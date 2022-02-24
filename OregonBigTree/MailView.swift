
import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    var recipient: String
    var subject: String
    var body: String

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}

struct MailSetUp: View {
    var legid: String
    var recipiented: String
    var prefix: String
    var measurenumber: Int
    var relatingto: String
    @State var positions = ["Oppose", "Support"]
    @State var selectedposition = "Support"
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    @State var reasoning: String = ""
    @AppStorage("FirstName") var firstname: String = ""
    @AppStorage("LastName") var lastname: String = ""
    @AppStorage("PhoneNumber") var phone: String = ""
    @AppStorage("fulladdress") var address: String = ""
    var body: some View {
        VStack {
            Form {
                Picker("Position on Measure", selection: $selectedposition) {
                    ForEach(positions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                TextField("Reasoning", text: $reasoning)
                TextField("First Name", text: $firstname)
                TextField("Last Name", text: $lastname)
                TextField("Phone Number", text: $phone)
            }
            Button("Submit Email") {
                self.isShowingMailView.toggle()
            }
            .disabled(!MFMailComposeViewController.canSendMail())
            .sheet(isPresented: $isShowingMailView) {
                let subjected = "Thoughts on \(self.prefix)\(self.measurenumber)"
                let message = "\(legid),<br /><br /> I am a constituent of your district writing to indicate that I \(selectedposition.lowercased()) \(prefix) \(measurenumber), \(relatingto)<br /><br />\(reasoning)<br /><br />Sincerely,<br /><br />\(firstname) \(lastname)<br />\(phone)<br />\(address.withReplacedCharacters("%20", by: " "))"
                MailView(result: self.$result, recipient: recipiented, subject: subjected, body: message)
            }
        }
    }
}
