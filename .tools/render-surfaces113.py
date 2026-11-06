"""Offline surface pass over the user-approved 11.2 geometry and cameras."""
import bpy,os,json,math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parent.parent
import argparse,sys,zipfile
parser=argparse.ArgumentParser()
parser.add_argument('--out',default=str(ROOT/'.tools/rendered113'))
args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]if '--'in sys.argv else [])
BASE=ROOT/'.tools/render-cache112';BASE.mkdir(exist_ok=True)
with zipfile.ZipFile(ROOT/'.tools/validated112/scenes.zip')as archive:
 for name in archive.namelist():assert(BASE/name).resolve().is_relative_to(BASE.resolve())
 archive.extractall(BASE)
OUT=Path(args.out).resolve();OUT.mkdir(parents=True,exist_ok=True)
house=json.loads((BASE/'house.json').read_text())
def material(name,color,kind='plaster'):
 m=bpy.data.materials.new(name);m.use_nodes=True
 n=m.node_tree.nodes;l=m.node_tree.links;p=n.get('Principled BSDF');p.inputs['Roughness'].default_value=.78
 coord=n.new('ShaderNodeTexCoord');mapping=n.new('ShaderNodeVectorMath');mapping.operation='MULTIPLY';mapping.inputs[1].default_value=(4,4,4)
 if kind=='wood':mapping.inputs[1].default_value=(3,40,3)
 if kind=='fabric':mapping.inputs[1].default_value=(85,85,85)
 l.new(coord.outputs['Generated'],mapping.inputs[0])
 noise=n.new('ShaderNodeTexNoise');noise.inputs['Scale'].default_value=2.5;noise.inputs['Detail'].default_value=3;l.new(mapping.outputs[0],noise.inputs['Vector'])
 ramp=n.new('ShaderNodeValToRGB');ramp.color_ramp.elements[0].position=.18;ramp.color_ramp.elements[1].position=.82
 low=.72 if kind=='plaster'else .60;high=1.10
 ramp.color_ramp.elements[0].color=tuple(v*low for v in color)+(1,)
 ramp.color_ramp.elements[1].color=tuple(min(1,v*high)for v in color)+(1,)
 l.new(noise.outputs['Fac'],ramp.inputs[0]);l.new(ramp.outputs[0],p.inputs['Base Color'])
 bump=n.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.15;bump.inputs['Distance'].default_value=.008 if kind!='fabric'else .003
 l.new(noise.outputs['Fac'],bump.inputs['Height']);l.new(bump.outputs[0],p.inputs['Normal'])
 return m
def box(name,pos,dim,mat):
 bpy.ops.mesh.primitive_cube_add(size=1,location=pos);o=bpy.context.object;o.name=name;o.dimensions=dim
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(mat)
 bevel=o.modifiers.new('Aresta acabamento','BEVEL');bevel.width=.004;bevel.segments=2
 return o
def picture(obj,index,wood):
 # Crop coordinates sample only the two pictures supplied by the user.
 path=os.environ.get('LUPI_PICTURES')
 if not path or not Path(path).exists():return
 image=bpy.data.images.load(path,check_existing=True)
 m=bpy.data.materials.new('Arte quadro '+str(index));m.use_nodes=True
 n=m.node_tree.nodes;l=m.node_tree.links;p=n.get('Principled BSDF')
 uv=n.new('ShaderNodeTexCoord');multiply=n.new('ShaderNodeVectorMath');multiply.operation='MULTIPLY'
 add=n.new('ShaderNodeVectorMath');add.operation='ADD'
 u0,v0,u1,v1=(.042,.44,.330,.765)if index==0 else(.574,.292,.925,.72)
 multiply.inputs[1].default_value=(u1-u0,v1-v0,1);add.inputs[1].default_value=(u0,v0,0)
 tex=n.new('ShaderNodeTexImage');tex.image=image;l.new(uv.outputs['UV'],multiply.inputs[0]);l.new(multiply.outputs[0],add.inputs[0]);l.new(add.outputs[0],tex.inputs['Vector']);l.new(tex.outputs['Color'],p.inputs['Base Color'])
 p.inputs['Roughness'].default_value=.8
 cy,cz=obj.location.y,obj.location.z
 mesh=bpy.data.meshes.new('Tela quadro');mesh.from_pydata([(.053,cy-.235,cz-.21),(.053,cy+.235,cz-.21),(.053,cy+.235,cz+.21),(.053,cy-.235,cz+.21)],[],[(0,1,2,3)])
 layer=mesh.uv_layers.new()
 for loop,uvcoord in zip(layer.data,[(0,0),(1,0),(1,1),(0,1)]):loop.uv=uvcoord
 art=bpy.data.objects.new('Imagem quadro '+str(index),mesh);bpy.context.scene.collection.objects.link(art);art.data.materials.append(m)
for room,meta in house.items():
 if os.environ.get('LUPI_ROOM')and room!=os.environ['LUPI_ROOM']:continue
 bpy.ops.wm.open_mainfile(filepath=str(BASE/(room+'.blend')));scene=bpy.context.scene
 original={o.name:(o.matrix_world.copy(),o.dimensions.copy())for o in scene.objects if o.type=='MESH'}
 camera=scene.camera;cameraMatrix=camera.matrix_world.copy();lens=camera.data.lens
 wood=material('Madeira envelhecida',(.19,.075,.029),'wood');paint=material('Reboco envelhecido',(.52,.47,.38))
 cloth=material('Trama do sofa',(.50,.19,.055),'fabric');rug=material('Trama tapete',(.35,.27,.14),'fabric')
 tileLight=material('Ceramica clara',(.49,.47,.39));tileDark=material('Ceramica escura',(.055,.065,.085))
 brass=material('Metal escuro',(.11,.12,.13));darkWood=material('Moldura escura',(.075,.026,.012),'wood')
 for obj in list(scene.objects):
  if obj.type!='MESH' or not obj.data.materials:continue
  name=obj.name
  if name.startswith(('Parede','Verga','Fundo lado','Reboco')):obj.data.materials.clear();obj.data.materials.append(paint)
  elif name.startswith('Ladrilho'):
   color=obj.data.materials[0].diffuse_color
   old=obj.data.materials[0].node_tree.nodes.get('Principled BSDF')
   base=old.inputs['Base Color'].default_value if old else color
   obj.data.materials.clear();obj.data.materials.append(tileLight if sum(base[:3])> .5 else tileDark)
  elif name.startswith(('Sofa encosto','Sofa braco','Sofa assento')):obj.data.materials.clear();obj.data.materials.append(cloth)
  elif name.startswith(('Mesa','Pe mesa','Cadeira','Pe cadeira','Balcao','Armario','Guarda roupa','Comoda','Bancada','Prateleira','Painel','Balanco')):obj.data.materials.clear();obj.data.materials.append(wood)
  elif name.startswith(('Tapete','Passadeira')):obj.data.materials.clear();obj.data.materials.append(rug)
  elif name.startswith('Quadro'):obj.data.materials.clear();obj.data.materials.append(darkWood)
 # Applied details stay on surfaces: no changes to approved obstacle footprints.
 w,d=meta['size']
 for side in ['back','left','right']:
  length=w if side=='back'else d;cuts=sorted(p[2]for p in meta['doors']if p[1]==side)
  intervals=[];edge=0
  for at in cuts+[length+.4]:
   if at-.4>edge:intervals.append((edge,at-.4))
   edge=at+.4
  for a,b in intervals:
   if side=='back':pos=((a+b)/2,d-.015,.075);dim=(b-a,.035,.15)
   else:pos=(.015 if side=='left'else w-.015,(a+b)/2,.075);dim=(.035,b-a,.15)
   box('Detalhe rodape',pos,dim,darkWood)
  for at in cuts:
   for offset in [-.43,.43]:
    pos=(at+offset,d-.015,1.075)if side=='back'else(.015 if side=='left'else w-.015,at+offset,1.075)
    box('Detalhe batente',pos,(.045,.045,2.15),darkWood)
   pos=(at,d-.015,2.15)if side=='back'else(.015 if side=='left'else w-.015,at,2.15)
   box('Detalhe batente superior',pos,(.91,.045,.055)if side=='back'else(.045,.91,.055),darkWood)
 if room=='sala':
  for i,o in enumerate(sorted([o for o in scene.objects if o.name.startswith('Quadro')],key=lambda o:o.location.y)):picture(o,i,darkWood)
  for yy in [2.055,2.845]:box('Sofa detalhe costura',(.302,yy,.70),(.012,.008,.47),darkWood)
  for xx in [1.28,3.32]:box('Detalhe borda tapete',(xx,2.45,.012),(.035,2.5,.008),darkWood)
  for yy in [1.21,3.69]:box('Detalhe borda tapete',(2.3,yy,.012),(2.1,.035,.008),darkWood)
 if room=='cozinha':
  for yy in [1.4,2.2,3.,3.8]:
   box('Detalhe frente gaveta',(3.092,yy,.68),(.012,.68,.19),darkWood)
   box('Detalhe puxador',(3.077,yy,.68),(.025,.19,.025),brass)
   box('Detalhe porta gabinete',(3.092,yy,.29),(.012,.68,.49),wood)
 if room=='quarto':
  for yy in [2.65,3.35]:
   box('Detalhe porta armario',(2.643,yy,1.05),(.012,.65,1.98),wood)
   box('Detalhe puxador armario',(2.627,yy,1.1),(.025,.025,.16),brass)
 if room=='garagem':
  for i in range(6):box('Detalhe ferramenta',(3.365,2.75+i*.26,1.5),(.025,.035,.28 if i%2 else .18),brass)
 if room in ['frente','quintal']:
  # Different surface treatment clarifies that these are exterior spaces.
  for o in original:
   obj=scene.objects.get(o)
   if obj and o.startswith('Parede'):obj.data.materials.clear();obj.data.materials.append(material('Reboco externo '+o,(.27,.30,.28)))
  soil=material('Terra canteiros',(.065,.04,.018))
  for o in list(scene.objects):
   if o.name.startswith('Canteiro'):
    box('Detalhe terra',(o.location.x,o.location.y,o.location.z+o.dimensions.z/2-.004),(o.dimensions.x*.92,o.dimensions.y*.92,.008),soil)
 # Keep illumination separate from the camera's dark surrounding background.
 world=scene.world;world.use_nodes=True;n=world.node_tree.nodes;l=world.node_tree.links
 output=n.get('World Output');old=output.inputs['Surface'].links[0].from_socket
 bg=n.new('ShaderNodeBackground');bg.inputs['Color'].default_value=(.009,.014,.025,1);bg.inputs['Strength'].default_value=1
 ray=n.new('ShaderNodeLightPath');mix=n.new('ShaderNodeMixShader');l.new(old,mix.inputs[1]);l.new(bg.outputs[0],mix.inputs[2]);l.new(ray.outputs['Is Camera Ray'],mix.inputs[0]);l.new(mix.outputs[0],output.inputs['Surface'])
 scene.cycles.samples=48;scene.cycles.use_denoising=True
 scene.render.resolution_x=960;scene.render.resolution_y=540;scene.render.film_transparent=False
 # Exact camera and original geometry are assertions, not visual guesses.
 for name,(matrix,dimensions)in original.items():
  obj=scene.objects[name];assert max(abs(obj.matrix_world[i][j]-matrix[i][j])for i in range(4)for j in range(4))<1e-7
  assert (obj.dimensions-dimensions).length<1e-7
 assert camera.matrix_world==cameraMatrix and camera.data.lens==lens
 scene.render.filepath=str(OUT/(room+'-fundo.png'));bpy.ops.render.render(write_still=True)
 bpy.ops.wm.save_as_mainfile(filepath=str(OUT/(room+'.blend')))
 if room in ['sala','garagem']:
  prefixes=('Sofa',)if room=='sala'else('Carroceria','Cabine','Paralama','Pneu','Calota','Parachoque','Farol','Para-brisa','Vidro traseiro','Janela')
  for o in scene.objects:o.hide_render=o.type not in ('LIGHT','CAMERA')and not o.name.startswith(prefixes)
  scene.render.film_transparent=True;scene.render.filepath=str(OUT/(room+'-mascara.png'));bpy.ops.render.render(write_still=True)
 print('SURFACE_ONLY_VALIDATED',room,flush=True)
(OUT/'house.json').write_text(json.dumps(house,indent=2))
