import SwiftUI

struct Cassette: View {
    @Binding var isRecording: Bool
    @State private var isRotatingLeft = 0.0
    @State private var isRotatingRight = 0.0
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("CasseteBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Rectangle()
                .fill(Color("CasseteForeground"))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(12)
            
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color("CasseteLabelTop"))
                        .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10.0, bottomLeading:0, bottomTrailing: 0, topTrailing: 10.0)))
                    
                    Rectangle()
                        .fill(Color("CasseteLabelBottom"))
                        .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 10, bottomTrailing: 10, topTrailing: 0)))
                }
                .padding(60)
                
                HStack(alignment: .center, spacing: 80) {
                    CasseteInset()
                        .rotationEffect(.degrees(isRecording ? isRotatingLeft : 0))
                        .onChange(of: isRecording, { oldValue, newValue in
                            if (newValue) {
                                withAnimation(.linear(duration: 4)
                                    .repeatForever(autoreverses: false)) {
                                        isRotatingLeft = isRecording ? -360.0 : 0.0
                                    }
                            } else {
                                isRotatingLeft = 0.0
                            }
                        })
                    CasseteInset()
                        .rotationEffect(.degrees(isRecording ? isRotatingRight : 0))
                        .onChange(of: isRecording, { oldValue, newValue in
                            if (newValue) {
                                withAnimation(.linear(duration: 4)
                                    .repeatForever(autoreverses: false)) {
                                        isRotatingRight = isRecording ? -360.0 : 0.0
                                    }
                            } else {
                                isRotatingRight = 0.0
                            }
                        })
                }
                .frame(height: 50)
            }
        }
        .frame(width: 900 / 2.5, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
