import SwiftUI

struct WinStreakView : View {
    
    let size:CGFloat
    
    init(size:CGFloat = 50){
        self.size = size
    }
    
    var body: some View {
        VStack{
            ZStack {
                FlameStreakView()
                    .frame(width:size, height:size)
                
                Text("4")
                    .font(Font.system(size: size/2, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 3)
                    .offset(y:5)
                
            }
            //Text("WIN\nSTREAK")
              //  .multilineTextAlignment(.center)
                
        }
        
    }
}


#Preview {
    HStack {
        WinStreakView(size:40)
        WinStreakView(size:50)
        WinStreakView(size:80)
    }
}
