### MM-GM is a 3D map-making tool built in GameMaker, designed to streamline the creation of environments using the SMF (Snidr Model Format) and Colmesh for collision handling, both developed by Snidr.
![ezgif-5-f764f8fdb3](https://github.com/user-attachments/assets/b214228d-4e85-4f5c-8a71-0083ddf773e3)

# Smf models are currently NOT supported

## Key Features:


# Object Manipulation:
    Select 3D objects directly in the view.
    Add objects by dragging them from the asset browser into the view.

# Camera Controls:
    Adjust camera speed using the mouse scroll or arrow keys.
    Activate Freecam by right-clicking and holding on the view.

# Editing Tools:

    Undo (Ctrl + Z) and Redo (Ctrl + Y) actions.
    Save your progress quickly with Ctrl + S.
    Press "A" to switch to position mode
    Press "S" to switch to scaling mode

# File Management:
    Export your map through the File menu, generating a ZIP file that contains data.json and the associated 3D models.
    Import 3D models via the File menu for easy integration into your project.

##Maps are saved as a ZIP file containing:

    data.json: Defines the placement, scale, and rotation of objects.
    Models Folder: Stores all 3D models with their textures and materials. Ensure filenames match, as mismatches currently prevent proper export.

# Example of an array entry that is inside of data.json

    data[i] = {
      "x": 10.5,
      "y": 3.2,
      "z": 7.8,
      "xScale": 1.0,
      "yScale": 1.0,
      "zScale": 1.0,
      "xRotation": 45.0,
      "yRotation": 0.0,
      "zRotation": 90.0,
      "model": {
        "name": "tree",
        "path": "models/tree/tree.obj"
      }
    }
