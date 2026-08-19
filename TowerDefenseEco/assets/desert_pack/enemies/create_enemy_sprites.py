from PIL import Image, ImageDraw
import os
root = os.path.dirname(__file__)
colors = [(120,200,255),(100,220,150),(255,200,90)]
for i, color in enumerate(colors):
    img = Image.new('RGBA',(128,128),(0,0,0,0))
    d = ImageDraw.Draw(img)
    d.ellipse((16,32,112,112), fill=color+(255,))
    d.rectangle((40,12,88,48), fill=(50,50,50))
    d.ellipse((56,50,72,66), fill=(255,100,50))
    d.polygon([(24,96),(104,96),(88,112),(40,112)], fill=(30,150,80))
    d.ellipse((28,100,100,120), fill=(0,0,0,100))
    name = f'enemy_def_{i}.png'
    path = os.path.join(root, name)
    img.save(path)
    print('created', name, img.size)
