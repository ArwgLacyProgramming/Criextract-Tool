import bpy, sys
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete()
bpy.ops.wm.collada_import(filepath="C:/Users/permi/OneDrive/Masaüstü/cvt2/husk/Scientist_GenMaleBody01.skinm.dae")