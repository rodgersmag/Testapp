//
//  ContentView.swift
//  Testapp
//
//  Created by rodgers magabo on 27/02/2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var date = Date()
    @State private var monthYear = ""
    @State private var year = ""
    @State private var selected = ""

    var body: some View {
        
        NavigationView {
         
            
           VStack {
               HStack {
                   Form {
                       DatePicker("Date", selection: $date, displayedComponents: .date)
                      
                   }
               } .frame(height: 100)
               
               HStack {
                   Button(action: addItem) {
                      Text("Save date")
                   }.buttonStyle(.bordered)
               }
               
//
               
              
               
               Picker("Test", selection: $selected) {
                   Text("Month").tag(monthYear)
                   Text("Year").tag(year)
                   Text("All time").tag(3)
               }.pickerStyle(.segmented)
                  
               
               if selected == monthYear {
                   HStack {
                       Picker("Month year", selection: $monthYear) {
                           let monthYearFetch = items.map {($0.monthYearString)}
                           let uniqueMonthyear = Array(Set(monthYearFetch))
                           ForEach(uniqueMonthyear, id: \.self) { month in
                               Text(month!).tag(month!)
                           }
                       }
                       Spacer(minLength: 0)
                   }
                   List {
                       ForEach(items) { item in
                           NavigationLink {
                               Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                           } label: {
       //                        Text(item.timestamp!, formatter: itemFormatter)
//                               Text(item.yearString ?? "")
                               Text(item.monthYearString ?? "")
                           }
                       }
                       .onDelete(perform: deleteItems)
                   }
               }
               else if selected == year {
                   HStack {
                       Picker("Year", selection: $year) {
                           let yearFetch = items.map {($0.yearString)}
                           let uniqueYear = Array(Set(yearFetch))
                           ForEach(uniqueYear, id: \.self) { month in
                               Text(month!).tag(month!)
                           }
                       }
                       Spacer(minLength: 0)
                   }
                   
                   List {
                       ForEach(items) { item in
                           NavigationLink {
                               Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                           } label: {
       //                        Text(item.timestamp!, formatter: itemFormatter)
                               Text(item.yearString ?? "")
//                               Text(item.monthYearString ?? "")
                           }
                       }
                       .onDelete(perform: deleteItems)
                   }
               }
               
               
              
                
                
                
//                List {
//                    ForEach(items) { item in
//                        NavigationLink {
//                            Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                        } label: {
//    //                        Text(item.timestamp!, formatter: itemFormatter)
//                            Text(item.yearString ?? "")
//                            Text(item.monthYearString ?? "")
//                        }
//                    }
//                    .onDelete(perform: deleteItems)
//                }
            } .padding()
            
           
            
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = date
            newItem.yearString = date.toYearString()
            newItem.monthYearString = date.toMonthYearString()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


extension Date {
    func toYearString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    
    func toMonthYearString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
