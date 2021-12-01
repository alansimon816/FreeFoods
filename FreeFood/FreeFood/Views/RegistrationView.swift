//
//  RegistrationView.swift
//  FreeFood
//
//  Created by user on 11/24/21.
//

import Foundation
import SwiftUI
import FirebaseFirestore

// This view is to be presented directly after a user successfully signs up
struct RegistrationView: View {
  @State var username = ""
  @State var firstName = ""
  @State var lastName = ""
  @State var selectedFoods: [String] = []
  @State var showLocationRequestView = false
  @State private var incomplete = false
  @State private var formError: FormError?
  
  var body: some View {
    if showLocationRequestView {
      LocationRequestView()
    } else {
      Form {
        Section(header: Text("USERNAME")) {
          TextField("Username", text: $username)
        }.autocapitalization(.none)
          .disableAutocorrection(true)
        Section(header: Text("NAME")) {
          TextField("First", text: $firstName)
          TextField("Last", text: $lastName)
        }.disableAutocorrection(true)
        Section(header: Text("FAVORITE FOODS")) {
          SelectMultipleList(selectedFoods: self.$selectedFoods)
        }
        Button("Submit", action: {
          if username == "" || username == "Username" {
            incomplete = true
            print("<DEBUG> Username was not entered.")
            formError = .usernameMissing
          }
          
          if firstName == "" || firstName == "First" {
            formError = .nameMissing
            print("<DEBUG> First name was not entered.")
            incomplete = true
          }
          
          if !incomplete {
            print("HELLOHELLOHELLOHELLOHELLOHELLOHELLOHELLOHELLOHELLOHELLOHELLOHELLO\n\n\n\n\n")
            self.storeUserDetails(username: username, firstName: firstName, lastName: lastName, favFoods: selectedFoods)
            showLocationRequestView = true
          }
        })
          .alert(isPresented: $incomplete) {
            Alert(title: Text(formError!.rawValue),
                  message: Text("Please enter missing info."),
                  dismissButton: .default(Text("OK")))
          }
      }
    }
  }
  
  func storeUserDetails(username: String, firstName: String, lastName: String, favFoods:[String]) -> Void {
    let sam = SimpleAuthModel()
    let db = Firestore.firestore()
    var UID = ""
    // Add a new document with a generated ID
    var ref: DocumentReference? = nil
    
    if let user = sam.auth.currentUser {
      //User is signed in
      UID = user.uid
    } else {
      //No user is signed in
      print("<DEBUG> No user is currently signed in")
    }
    
    ref = db.collection("users").addDocument(data: [
      "First Name": firstName,
      "Last Name": lastName,
      "Favorite Food Types": favFoods,
      "UID": UID
    ]) { err in
      if let err = err {
        print("Error adding document: \(err)")
      } else {
        print("Document added with ID: \(ref!.documentID)")
      }
    }
  }
}

enum FormError: String {
  case usernameMissing = "Username Missing"
  case nameMissing = "Name Missing"
  case bothMissing = "Username and Name Missing"
}

struct FoodRow: View {
  var food: String
  var selected: Bool
  var action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Text(food)
        if self.selected {
          Spacer()
          Image(systemName: "checkmark")
        }
      }
    }
  }
}

struct SelectMultipleList: View {
  @Binding var selectedFoods: [String]
  @State var foods: [String] = getFoods()
  
  var body: some View {
    List {
      ForEach(self.foods, id: \.self) { food in
        FoodRow(food: food, selected: self.selectedFoods.contains(food)) {
          if self.selectedFoods.contains(food) {
            self.selectedFoods.removeAll(where: { $0 == food })
          }
          else {
            self.selectedFoods.append(food)
          }
        }
      }
    }
  }
}
