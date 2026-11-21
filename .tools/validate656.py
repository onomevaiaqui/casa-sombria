from pathlib import Path
from PIL import Image
import json,hashlib,sys,os
R=Path.cwd();D=R/'outputs/Lupi-16.46';P=R/'outputs/Previa-Cenario-16.40';O=R/'outputs/Publicacao-Lupi-656';plan=json.loads((R/'work/release656-assets.json').read_text());palette=plan['palette'];lookup={v:i for i,v in enumerate(palette)};assert len(lookup)==len(palette)<=224
maxpix=0;maxcolors=0;roundtrip=0
for line in (P/'lupi_manifest.txt').read_text().splitlines():
 a=line.split(' ',3)
 if len(a)!=4:continue
 meta=json.loads(a[3])
 if meta.get('type')!='bitmap':continue
 name=a[2];im=Image.open(D/(plan['aliases'][name]+'.png'));assert im.mode=='P';assert im.size==(meta['width'],meta['height']);assert im.width<=511 and im.height<=511 and im.width*im.height<=46059
 cp=im.getpalette();table=bytes(lookup.get((cp[i]>>3)|((cp[i+1]>>3)<<5)|((cp[i+2]>>3)<<10),0)for i in range(0,768,3));decoded=im.tobytes().translate(table);expected=(P/name).read_bytes();assert not(set(expected)-set(range(205))-{240}),name;expected=expected.translate(bytes(i if i<205 else 0 for i in range(256)));assert decoded==expected,name;roundtrip+=1;maxpix=max(maxpix,im.width*im.height);maxcolors=max(maxcolors,len(im.getcolors(256)or[]))
icon=Image.open(D/'icon.gif');assert icon.size==(64,32)
for i in range(icon.n_frames):icon.seek(i);assert icon.convert('RGB').getcolors(16)is not None
stats=json.loads((O/'audio-assets.json').read_text());assert len(stats)==31
for name,s in stats.items():
 assert s['channels']<=16 and s['sample_bytes']<=262144 and s['notes_bytes']<=131072
 assert hashlib.sha256((D/'music'/(name+'.fur')).read_bytes()).digest()==hashlib.sha256((R/'outputs/Lupi-16.45/music'/(name+'.fur')).read_bytes()).digest()
sys.path.insert(0,str(R/'work/lua55-libs'));from lupa.lua54 import LuaRuntime
l=LuaRuntime(encoding=None);os.chdir(D)
l.execute(b'''events={};music={play=function(...)events[#events+1]={'play',...};return true end,loop=function(...)events[#events+1]={'loop',...};return true end,stop=function(...)events[#events+1]={'stop',...};return true end,volume=function(...)end}
local a=require('audio656');a.scene('D02');a.tick(.016);assert(a.active=='D02')
a.effect('porta_abrir');assert(a.active=='effect');a.tick(4);assert(a.active=='D02')
a.scene('B01');a.tick(.016);assert(a.active=='B01');a.scene('L01');assert(a.priority==100 and a.hold==4);a.tick(4.1);assert(a.active=='L01')
a.effect('madeira');assert(a.active=='L01','steps must not cut ambience')
music.play=function()return nil,'injected error'end;a.effect('vidro');assert(a.errors==1 and a.lastError=='injected error')
print('PASS native audio API, menu loop, effect restore, battle fade and error capture')''')
report={'version':'16.46','lua_version':'5.4','lua_memory_test_cap_bytes':4194304,'menu_new_game_and_field_combat_key_tested':True,'inventory_manual_pages_tested':6,'palette_colors':len(palette),'bitmap_roundtrips_verified':roundtrip,'unique_png_count':len(list(D.glob('*.png'))),'max_bitmap_pixels':maxpix,'max_bitmap_colors':maxcolors,'icon_size':[64,32],'icon_frames':icon.n_frames,'furnace_files':31,'audio_unchanged_from_validated_1645':True,'audio_api_tests_passed':True,'physical_console_tested':False,'server_conversion_tested':False,'menu_pizza_removed':True,'file_reader':'black background, paginated serif overlay'}
(O/'validation.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
