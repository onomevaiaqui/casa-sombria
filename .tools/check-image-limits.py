"""Validate source PNGs as the Lupi pipeline does, before native conversion.

ImageMagick counts source colours including alpha; transparent pixels with
different RGB values can exceed 256 even when the native palette fits.
"""
from pathlib import Path
import argparse, shutil, subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--magick', default=shutil.which('magick'))
args = parser.parse_args()
if not args.magick:
    parser.error('ImageMagick is required: use --magick /path/to/magick')
root = Path(__file__).resolve().parent.parent
count = 0
for path in sorted(root.glob('*.png')):
    result = subprocess.check_output(
        [args.magick, 'identify', '-format', '%w %h %k', str(path)], text=True)
    width, height, colours = map(int, result.split())
    assert width <= 512 and height <= 512, f'{path.name}: dimensions exceed 512'
    assert colours <= 256, f'{path.name}: {colours} source colours exceed 256'
    assert width * height <= 46059, f'{path.name}: native 8bpp image exceeds 46059 bytes'
    count += 1
print(f'{count} source PNGs pass ImageMagick colour, dimension and native-memory limits')
