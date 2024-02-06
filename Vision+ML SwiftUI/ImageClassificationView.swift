//
//  ImageClassificationView.swift
//  Vision+ML SwiftUI
//
//  Created by MacBook Pro on 2021/07/11.
//

import SwiftUI
import Glur
import VariableBlurImageView

struct ImageClassificationView: View {
    @State private var isPresented = false
    @State private var sourceType = UIImagePickerController.SourceType.photoLibrary
    @State private var image: UIImage?
    
    // image classifier
    @ObservedObject var classification = ImageClassification()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // display the image
            if let image = self.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .glur(offset: 0.3,
                          interpolation: 0.2,
                          radius: 4.0,
                          direction: .down)
                    .overlay {
                        LinearGradient(stops: [.init(color: .clear, location: 0.7), .init(color: .white.opacity(0.2), location: 0.85)], startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                    }
            }
            else {
                Image(uiImage: UIImage())
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }

            VStack(spacing: 24) {
                // display the classification result
                Text(classification.classificationLabel)
                    .padding(20)
                    .foregroundColor(.black)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.secondary)
                        )
            
                // select camera or photo library
                Menu {
                    Button(action: {
                        self.isPresented.toggle()
                        self.sourceType = .camera
                    }, label: {
                        Text("Take Photo")
                    })
                    
                    Button(action: {
                        self.isPresented.toggle()
                        self.sourceType = .photoLibrary
                    }, label: {
                        Text("Choose Photo")
                    })
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: 64, height: 64)
                        Image(systemName: "camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.white)
                            .padding(5)
                    }
                }
                .sheet(isPresented: $isPresented, onDismiss: {
                    // Classify the image
                    if let image = self.image {
                        classification.updateClassifications(for: image)
                    }
                }, content: {
                    ImagePicker(sourceType: self.sourceType, image: $image)
                })
            }
        }
    }
}

// MARK: - ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
    
    // MARK: - Using Coordinator to Adopt the UIImagePickerControllerDelegate Protocol
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.image = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ImageClassificationView_Previews: PreviewProvider {
    static var previews: some View {
        ImageClassificationView()
    }
}
