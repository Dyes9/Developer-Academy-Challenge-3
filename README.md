# Apple Developer Academy - Challenge 3
# "Tagify: a simple picture auto-tagger" 
---------------------------------------
## App description

This iOs app prototype is a simple tool that allows to automatically generate tags for your pictures.
This can be particularly useful for social media posting.

The app makes use of Imagga's image recognition API

##About Imagga

*"Imagga is an Platform-as-a-Service providing Image recognition API that help business
understand and monetize image content in the cloud and on-premise."*

More about on the offical website https://imagga.com 

----------------------------------------
## How it works
1) When the user uploads one or more images, the images are sent to Imagga via with a POST request.
The output of this operation is a series of tags for each of the uploaded pictures

*Example: Image_of_flowers : #nature, #plants, #gardening 

