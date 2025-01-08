import SwiftUI

struct ProfileImageView: View {
    let user: User
    let profileImage: UIImage?
    let size: CGFloat
    let showEditButton: Bool
    let onEditTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Profile Image or Placeholder
            Group {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            
            // Edit Button
            if showEditButton {
                Button(action: onEditTap) {
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: size * 0.3, height: size * 0.3)
                        .foregroundColor(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .offset(x: 3, y: 3)
            }
        }
    }
}

#Preview {
    ProfileImageView(
        user: User.preview,
        profileImage: nil,
        size: 80,
        showEditButton: true,
        onEditTap: {}
    )
} 
