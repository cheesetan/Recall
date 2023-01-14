//
//  MIVCInfoSwiftUI.swift
//  Recall
//
//  Created by Tristan on 7/8/22.
//

import SwiftUI

struct MIVCInfoSwiftUI: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Editing Product Info")) {
                        Text("FAQ: Why can't I edit this item's title and expiration date?")
                            .fontWeight(.bold)
                            .padding(.vertical, 5)
                        Text("To protect the legitimacy of the product's title and expiration date, products with the green verified checkmark cannot have its expiration date and title altered.\n\nProducts can only obtain the checkmark if they are from real Recall QR Codes on packagings, and of which has the accurate product's title and expiration date.")
                            .padding(.vertical, 10)
                        HStack {
                            Text("Example of the green verified checkmark:")
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    Section() {
                        Text("FAQ: Why can products without the green verified checkmark have its information changed?")
                            .fontWeight(.bold)
                            .padding(.vertical, 5)
                        Text("Products without the green verified checkmark means that it has been added manually by the user under the \"Scan QR > \"plus\" button\" section. This means that the product's expiration date cannot be verified to be legitmate by Recall as the user had entered that information on their own")
                            .padding(.vertical, 10)
                    }
                    Section() {
                        Text("FAQ: Why do you even allow users to change the product's information anyways?")
                            .fontWeight(.bold)
                            .padding(.vertical, 5)
                        Text("This is just in case the user has entered the wrong information, and it allows them to easily be able to change the item's title and expiration date without adding another instance of the item.")
                            .padding(.vertical, 10)
                    }
                    Section() {
                        Text("FAQ: Why does Recall have to verify product expiration dates?")
                            .fontWeight(.bold)
                            .padding(.vertical, 5)
                        Text("This is so that users know that the information of the product shared in the \"Social\" tab is legitimate, and for users to be more wary and skeptical of products that had its information altered or the expiration date manually entered by an unverified source, which could leave to false expiration dates.\n\nPlease double check the expiration date from the other user if the product title does not have a green verified checkmark next to it!")
                            .padding(.vertical, 10)
                    }
                }
            }
            .navigationBarTitle("Help & FAQ", displayMode: .large)
            .navigationBarItems(
                trailing:
                    Button {
                        generator.impactOccurred(intensity: 0.7)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MIVCInfoSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        MIVCInfoSwiftUI()
    }
}
