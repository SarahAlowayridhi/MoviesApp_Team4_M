//
//  AddReviewView.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 10/07/1447 AH.
//



import SwiftUI

struct AddReviewView: View {
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack (spacing: 24) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                    .foregroundColor(.yellow)
                }

                Spacer()

                Text("Write a review")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)


                Spacer()

                Button {
                    
                } label: {
                    Text("Add")
                        .foregroundColor(.yellow)
                }
                
            }
            
            .padding(.horizontal)
            
            Divider()
            
            Text("Review")
                .font(.headline)
                .fontWeight(.medium)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Add a review", text: .constant(""))
                .frame(height: 146)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding(.horizontal)
            
            HStack{
                
                Text("Rating")
                    .font(.headline)
                    .fontWeight(.medium)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "star")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                
                Image(systemName: "star")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                
                Image(systemName: "star")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                
                Image(systemName: "star")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                
                Image(systemName: "star")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
            
            }
            
            Spacer()
                
        }.padding()
    }
}

#Preview {
 
  AddReviewView()
    
}
