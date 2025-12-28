import SwiftUI

struct ProfileView: View {
    var body: some View {
        
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 24) {
                
                NavigationLink(destination: SignInView()) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.yellow)
                        
                        Text("Back")
                            .font(.title3)
                            .foregroundColor(.yellow)
                    }
                }
                
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                ZStack {
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.35))
                        .frame(height: 110)
                        .cornerRadius(16)
                    
                    HStack(spacing: 16) {
                        
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 80)
                            
                            Image("profilephoto")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Sarah Abdullah")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text("Xxxx234@gmail.com")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }
                
                Text("Saved movies")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                Spacer()
                
                VStack(spacing: 12) {
                    
                    Image("movieisme logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 73.07, height: 43.66)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("No saved movies yet, start save\nyour favourites")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView()
}

