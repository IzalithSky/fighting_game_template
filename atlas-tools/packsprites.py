from PIL import Image
import os
import re

sprites_dir = '/some/path/dir/'
output_file = '/some/path/dir/attack_ranged.png'
sprite_width = 160
sprite_height = 160

def numerical_sort(value):
    numbers = re.findall(r'\d+', value)
    return int(numbers[0]) if numbers else 0

sprite_files = [f for f in os.listdir(sprites_dir) if f.endswith('.png')]
sprite_files.sort(key=numerical_sort)

sprites = [Image.open(os.path.join(sprites_dir, f)) for f in sprite_files]

sheet_width = sprite_width * 12
sheet_height = sprite_height * 1
spritesheet = Image.new('RGBA', (sheet_width, sheet_height))

for index, sprite in enumerate(sprites):
    x = (index % 12) * sprite_width
    y = (index // 12) * sprite_height
    spritesheet.paste(sprite, (x, y))

spritesheet.save(output_file)
print(f"Spritesheet saved as {output_file}")
