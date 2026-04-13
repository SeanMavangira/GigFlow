//
//  EditCurrency.swift
//  GigFlow
//
//  Created by Sean Mavangira on 9/4/2026.
//

import SwiftUI

struct EditCurrency: View {
    @Binding var selectedCurrency: String
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    
    let currencies = Locale.commonISOCurrencyCodes.sorted()

   
    var filteredCurrencies: [String] {
        if searchText.isEmpty {
            return currencies
        } else {
            return currencies.filter { code in
                code.contains(searchText.uppercased()) ||
                currencyFullName(for: code).localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        List(filteredCurrencies, id: \.self) { code in
            Button {
                selectedCurrency = code
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(code)
                            .font(.headline)
                            .foregroundStyle(.black)
                        Text(currencyFullName(for: code))
                            .font(.subheadline)
                            .foregroundStyle(.black)
                    }
                    
                    Spacer()
                    
                    if code == selectedCurrency {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .navigationTitle("Select Currency")
        .searchable(text: $searchText, prompt: "Search for a currency")
    }

   
    func currencyFullName(for code: String) -> String {
        let locale = Locale.current
        return locale.localizedString(forCurrencyCode: code) ?? ""
    }
}

#Preview {
    EditCurrency(selectedCurrency: .constant("USD"))
}
