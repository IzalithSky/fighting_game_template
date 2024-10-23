#target photoshop

function main() {
    // Save the current ruler units and set to pixels
    var originalRulerUnits = app.preferences.rulerUnits;
    app.preferences.rulerUnits = Units.PIXELS;

    if (!documents.length) {
        alert("No documents are open.");
        return;
    }

    var doc = app.activeDocument;

    // Show a dialog to the user to choose export option
    var userChoice = showExportOptionsDialog();

    if (userChoice == 'cancel') {
        // User cancelled
        return;
    }

    var groupsToProcess = [];

    if (userChoice == 'all') {
        // Get all groups
        var groups = getAllGroups(doc);

        if (groups.length == 0) {
            alert("No groups found in the document.");
            return;
        }
        groupsToProcess = groups;
    } else if (userChoice == 'selected') {
        // Get selected group
        var group = getSelectedGroup(doc);
        if (!group) {
            alert("Please select a group (layer set) to process.");
            return;
        }
        groupsToProcess.push(group);
    }

    for (var g = 0; g < groupsToProcess.length; g++) {
        var group = groupsToProcess[g];
        processGroup(group);
    }

    // Restore the original ruler units
    app.preferences.rulerUnits = originalRulerUnits;

    alert("Sprite sheet(s) created and saved successfully!");
}

function showExportOptionsDialog() {
    var dlg = new Window('dialog', 'Export Options');
    dlg.orientation = 'column';
    dlg.alignChildren = 'fill';

    dlg.add('statictext', undefined, 'Choose export option:');

    var btnGroup = dlg.add('group');
    btnGroup.orientation = 'row';
    btnGroup.alignChildren = 'fill';

    var btnAllGroups = btnGroup.add('button', undefined, 'Export All Groups');
    var btnSelectedGroup = btnGroup.add('button', undefined, 'Export Selected Group');
    var btnCancel = btnGroup.add('button', undefined, 'Cancel');

    var userChoice = null;

    btnAllGroups.onClick = function() {
        userChoice = 'all';
        dlg.close();
    }
    btnSelectedGroup.onClick = function() {
        userChoice = 'selected';
        dlg.close();
    }
    btnCancel.onClick = function() {
        userChoice = 'cancel';
        dlg.close();
    }

    dlg.show();

    return userChoice;
}

function getAllGroups(doc) {
    var groups = [];
    function collectGroups(layers) {
        for (var i = 0; i < layers.length; i++) {
            var layer = layers[i];
            if (layer.typename === "LayerSet") {
                groups.push(layer);
                // Uncomment the line below to include nested groups
                // collectGroups(layer.layers);
            }
        }
    }
    collectGroups(doc.layers);
    return groups;
}

function processGroup(group) {
    var doc = app.activeDocument;
    var frames = [];

    // Save the current visibility of layers in the group
    var initialGroupVisibility = [];
    for (var i = 0; i < group.layers.length; i++) {
        initialGroupVisibility.push(group.layers[i].visible);
    }

    // Hide all layers except the group
    var initialOtherVisibility = hideAllOtherLayers(doc, group);

    // Initialize group bounds
    var groupLeft = null;
    var groupTop = null;
    var groupRight = null;
    var groupBottom = null;

    // Collect frames and calculate group bounds
    for (var i = 0; i < group.layers.length; i++) {
        var layer = group.layers[i];

        if (layer.kind == LayerKind.NORMAL) {

            // Make only this layer visible within the group
            hideAllLayersInGroup(group);
            layer.visible = true;

            // Get the bounds of the layer content
            var bounds = layer.bounds; // [left, top, right, bottom]

            var left = bounds[0].as('px');
            var top = bounds[1].as('px');
            var right = bounds[2].as('px');
            var bottom = bounds[3].as('px');

            // Update group bounds
            if (groupLeft === null || left < groupLeft) {
                groupLeft = left;
            }
            if (groupTop === null || top < groupTop) {
                groupTop = top;
            }
            if (groupRight === null || right > groupRight) {
                groupRight = right;
            }
            if (groupBottom === null || bottom > groupBottom) {
                groupBottom = bottom;
            }

            frames.push({
                layer: layer,
                bounds: bounds,
                width: right - left,
                height: bottom - top
            });
        }
    }

    if (frames.length == 0) {
        alert("No frames found in group '" + group.name + "'.");
        // Restore visibility of group's layers
        for (var i = 0; i < group.layers.length; i++) {
            group.layers[i].visible = initialGroupVisibility[i];
        }
        // Restore visibility of other layers
        restoreOtherLayersVisibility(initialOtherVisibility);
        return;
    }

    // Calculate frame size based on group bounds
    var frameWidth = groupRight - groupLeft;
    var frameHeight = groupBottom - groupTop;

    // Create a new document for the sprite sheet
    var spriteSheetWidth = frameWidth * frames.length;
    var spriteSheetHeight = frameHeight;
    var spriteSheetDoc = app.documents.add(spriteSheetWidth, spriteSheetHeight, doc.resolution, "SpriteSheet", NewDocumentMode.RGB, DocumentFill.TRANSPARENT);

    // Process each frame
    for (var i = 0; i < frames.length; i++) {
        var frame = frames[i];
        var layer = frame.layer;
        var bounds = frame.bounds;

        // Calculate the offset to maintain original positioning relative to group bounds
        var layerLeft = bounds[0].as('px');
        var layerTop = bounds[1].as('px');
        var offsetX = layerLeft - groupLeft;
        var offsetY = layerTop - groupTop;

        // Duplicate the layer directly into the sprite sheet
        app.activeDocument = doc; // Ensure 'doc' is active
        doc.activeLayer = layer;
        layer.duplicate(spriteSheetDoc, ElementPlacement.PLACEATEND);

        app.activeDocument = spriteSheetDoc;
        var pastedLayer = spriteSheetDoc.activeLayer;

        // Get the bounds of the pasted layer
        var layerBounds = pastedLayer.bounds;
        var currentLeft = layerBounds[0].as('px');
        var currentTop = layerBounds[1].as('px');

        // Calculate the desired position
        var desiredLeft = frameWidth * i + offsetX;
        var desiredTop = offsetY;

        // Calculate how much to move the layer
        var deltaXSprite = desiredLeft - currentLeft;
        var deltaYSprite = desiredTop - currentTop;

        // Move the layer to the correct position
        pastedLayer.translate(deltaXSprite, deltaYSprite);
    }

    // Get the group name
    var groupName = group.name;

    // Construct the save file path
    var saveFile;
    if (doc.path) {
        saveFile = new File(doc.path + "/" + groupName + ".png");
    } else {
        // If the original document has not been saved, prompt the user to choose a save location
        saveFile = File.saveDialog("Choose a location to save the sprite sheet for group '" + groupName + "'", "*.png");
        if (saveFile == null) {
            alert("No save location selected. Sprite sheet for group '" + groupName + "' not saved.");
            // Restore visibility of group's layers
            for (var i = 0; i < group.layers.length; i++) {
                group.layers[i].visible = initialGroupVisibility[i];
            }
            // Restore visibility of other layers
            restoreOtherLayersVisibility(initialOtherVisibility);
            return;
        }
    }

    // Save the sprite sheet document as PNG
    var pngSaveOptions = new PNGSaveOptions();
    pngSaveOptions.compression = 0; // Highest quality

    app.activeDocument = spriteSheetDoc;
    spriteSheetDoc.saveAs(saveFile, pngSaveOptions, true, Extension.LOWERCASE);

    // Optionally close the sprite sheet document
    spriteSheetDoc.close(SaveOptions.DONOTSAVECHANGES);

    // Restore the visibility of layers in the group
    for (var i = 0; i < group.layers.length; i++) {
        group.layers[i].visible = initialGroupVisibility[i];
    }

    // Restore visibility of other layers
    restoreOtherLayersVisibility(initialOtherVisibility);
}

function hideAllLayersInGroup(group) {
    for (var i = 0; i < group.layers.length; i++) {
        group.layers[i].visible = false;
    }
}

function hideAllOtherLayers(doc, group) {
    var initialVisibility = [];
    for (var i = 0; i < doc.layers.length; i++) {
        var layer = doc.layers[i];
        if (layer != group) {
            initialVisibility.push({layer: layer, visible: layer.visible});
            layer.visible = false;
        }
    }
    return initialVisibility;
}

function restoreOtherLayersVisibility(initialVisibility) {
    for (var i = 0; i < initialVisibility.length; i++) {
        initialVisibility[i].layer.visible = initialVisibility[i].visible;
    }
}

function getSelectedGroup(doc) {
    app.activeDocument = doc;
    var ref = new ActionReference();
    ref.putEnumerated(charIDToTypeID('Lyr '), charIDToTypeID('Ordn'), charIDToTypeID('Trgt'));
    var desc = executeActionGet(ref);

    if (desc.hasKey(stringIDToTypeID('layerSection'))) {
        var type = desc.getEnumerationValue(stringIDToTypeID('layerSection'));
        var typeString = typeIDToStringID(type);
        if (typeString == 'layerSectionStart') {
            // It's a group
            var groupName = desc.getString(charIDToTypeID('Nm  '));
            var group = doc.layerSets.getByName(groupName);
            return group;
        }
    }

    return null;
}

main();
