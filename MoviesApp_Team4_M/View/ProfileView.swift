import SwiftUI

struct ProfileView: View {
    var body: some View {
        
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 20) {
                
                NavigationLink(destination: SignInView()) {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.yellow)
                        
                        Text("Back")
                            .font(.title3)
                            .foregroundColor(.yellow)
                        
                        Spacer()
                    }
                }
                
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                ZStack {
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.40))
                        .frame(height: 110)
                        .cornerRadius(15)
                    
                    HStack(spacing: 15) {
                        
                        ZStack{
                            Circle()
                                  .fill(Color.gray.opacity(0.3))
                                  .frame(width: 80, height: 80)

                            Image("profilephoto")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sarah Alowayridhi")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text("sarah.alowayridhi@gmail.com")
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
                    .font(.title)
                    .fontWeight(.semibold)
                
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView()
}

