//
//  ProfileInfo.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 08/07/1447 AH.
//

import SwiftUI

struct ProfileInfoView: View {
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 24) {
                
                HStack {
                    Button {
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                        .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    Text("Profile info")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                    } label: {
                        Text("Edit")
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 110, height: 110)
                    
                    Image("profilephoto")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                }
                .padding(.top, 8)
                
                VStack(spacing: 0) {
                    
                    HStack {
                        Text("First name")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Sarah")
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Divider()
                    
                    HStack {
                        Text("Last name")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Abdullah")
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.35))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                } label: {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.35))
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    ProfileInfoView()
}


