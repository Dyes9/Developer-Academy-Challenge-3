# Apple Developer Academy - Challenge 3
---------------------------------------
This iOs Application prototype allows to create short stories based on pictures uploaded by the user.
## Descritpion
This project makes use of two different APIs:
- ### Imagga API
  for image recognition and tagging

    *https://imagga.com*
  
- ### OpenAI ChatGPT API
  for the creation of generative text
  
   *https://platform.openai.com*
----------------------------------------
## How it works
1) When the user uploads one or more images, the images are sent to Imagga via API POST request.
The output of this operation is a series of tags for each of the uploaded pictures

*Example: Image1 : [Tag1, Tag2, Tag3]*

3) The tags of the images are then used to make a prompt for OpenAI's GPT.

*Example: "Create a short story, max 500 characters, inspired by the following tags": [Tag1, Tag2, Tag3]*
  
