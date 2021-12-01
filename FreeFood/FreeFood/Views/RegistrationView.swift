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
  @State private var username = ""
  @State private var firstName = ""
  @State private var lastName = ""
  @State private var selectedFoods: [String] = []
  @State private var showAppView = false
  @State private var search: String = ""
  @ObservedObject var lm = LocationManager.shared
  
  var body: some View {
      if showAppView {
          AppView()
      } else {
          Form {
            Section(header: Text("USERNAME")) {
              TextField("Username", text: $username)
            }
            Section(header: Text("NAME")) {
              TextField("First", text: $firstName)
              TextField("Last", text: $lastName)
            }
            Section(header: Text("FAVORITE FOODS")) {
              SelectMultipleList(selectedFoods: self.$selectedFoods)
            }
            Button("Submit") {
              lm.requestLocation()
                //LocationManager.shared.requestLocation()
              self.storeUserDetails(username: username, firstName: firstName, lastName: lastName, favFoods: selectedFoods)
              showAppView = true
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
      "Username": username,
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
