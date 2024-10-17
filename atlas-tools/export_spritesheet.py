group_name = "7 - Jump Backward"
image_dir = "/some/path/dir/"
image = gimp.image_list()[0]
drawable = pdb.gimp_image_get_active_layer(image)
canvas_width = pdb.gimp_image_width(image)
canvas_height = pdb.gimp_image_height(image)

for group in image.layers:
    if pdb.gimp_item_is_group(group) and group.name == group_name:
        for layer in group.children:
            if pdb.gimp_item_is_layer(layer):
                temp_image = pdb.gimp_image_new(canvas_width, canvas_height, image.base_type)
                temp_layer = pdb.gimp_layer_new(temp_image, canvas_width, canvas_height, layer.type, "Temp Layer", 100, LAYER_MODE_NORMAL)
                pdb.gimp_image_insert_layer(temp_image, temp_layer, None, 0)
                pdb.gimp_edit_copy(layer)
                floating_sel = pdb.gimp_edit_paste(temp_layer, True)
                pdb.gimp_floating_sel_anchor(floating_sel)
                pdb.gimp_layer_set_offsets(temp_layer, layer.offsets[0], layer.offsets[1])
                file_name = "%s/%s.png" % (image_dir, layer.name)
                pdb.file_png_save(temp_image, temp_layer, file_name, file_name, 0, 9, 1, 1, 1, 1, 1)
                pdb.gimp_image_delete(temp_image)
