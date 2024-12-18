# **Apple Developer Academy - Challenge 3**  
## **Tagify: A Simple Picture Auto-Tagger**  

### **Overview**  
Tagify is an iOS app prototype designed to streamline the process of generating tags for your pictures.  
Whether you're a social media enthusiast or someone looking to organize their photo collection efficiently, Tagify simplifies tagging by utilizing **Imagga's image recognition API** to automatically identify and suggest tags based on your images.  

---

### **Features**  
- Upload one or multiple images to the app.  
- Automatically receive suggested tags based on the content of your images.  
- Save a history of your tagged images for future reference.  
- User-friendly interface with simple upload and tag generation workflows.  

This app is ideal for anyone who frequently posts on social media or works with image content and needs quick, reliable tagging assistance.

---

### **About Imagga**  

> *"Imagga is a Platform-as-a-Service providing Image Recognition APIs that help businesses understand and monetize image content in the cloud and on-premise."*  

Imagga offers powerful image analysis tools capable of detecting objects, scenes, and attributes in pictures, which makes it perfect for applications like Tagify.  

For more information, visit [Imagga's official website](https://imagga.com).  

---

### **How It Works**  

1. **Upload Images:**  
   Select one or more pictures from your device using the app's built-in photo picker.  

2. **Image Analysis:**  
   The app sends your uploaded images to the **Imagga API** via a secure POST request.  

3. **Receive Tags:**  
   Imagga processes your images and returns a list of descriptive tags for each picture. These tags can then be used for organizing or sharing your photos.  

   #### Example:  
   - **Uploaded Image:** A bouquet of flowers  
   - **Suggested Tags:** `#nature`, `#plants`, `#gardening`  

4. **View and Save History:**  
   Access previously tagged images in the **History** section, complete with their associated tags.  

---

### **Installation and Setup**  

1. Clone the repository:  
   ```bash
   git clone https://github.com/yourusername/tagify.git
   cd tagify
      ```
   
2. Open the project in Xcode
3. Set up your Imagga API credentials
- Create a free account on [Imagga](https://imagga.com)
- Obtain your API and Secret
- Add your credentials to the appropriate variables in the code (apiKey and apiSecret in PhotoView)
4. Run the project on Xcode or your iPhone
