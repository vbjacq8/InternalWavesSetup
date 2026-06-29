#Standar libraries
import numpy as np
import pickle
import sys
from tqdm import tqdm
# import matplotlib.pyplot as plt
import cv2
import time
import os
from tkinter import Tcl
from numpy.core.numeric import empty_like
from progress.bar import Bar
from scipy.io import savemat,loadmat
#DPIVSoft libraries
import dpivsoft.DPIV as DPIV      #Python PIV implementation
import dpivsoft.Cl_DPIV as Cl_DPIV   #OpenCL PIV implementation
import dpivsoft.SyIm as SyIm  #Syntetic images generator
import matplotlib.pyplot as plt 
from dpivsoft.Classes  import Parameters
from dpivsoft.Classes  import grid
# from dpivsoft.Classes  import GPU
from dpivsoft.Classes  import Synt_Img
def pause():
    programPause = input("Press the <ENTER> key to continue...")
start = time.time()
#=========================================================================================================
#WORKING FOLDERS
#=========================================================================================================
dirCode = os.getcwd()   #Current path
dirImg = [dirCode + "/Camera "+str(i)+"/" for i in range(1,4)]   #Images folder
dirRes = [dirCode + "/Camera "+str(i)+"/results_gpu_fine_2/" for i in range(1,4)]  #Results folder
dirCompositeImage='compositeImages_3/'
if not os.path.exists(dirCompositeImage):os.makedirs(dirCompositeImage)
# #Select platform (only needed once). If more than one platform is installed use "selection"
thr = Cl_DPIV.select_Platform(0)
os.environ['PYOPENCL_COMPILER_OUTPUT'] = '0'
#=========================================================================================================
#SET PIV PARAMETERS
#=========================================================================================================
# 1: Set parameters manually (see Classes.py for more details):
# Parameters.box_size_2_x = 32

# # 2: Arternateively parameters can be load from a file calling readParamters method:
Parameters.readParameters(dirCode+'/Tutorial_2_parameters.yaml')

xextrema=((0,1656+138),(1656-138,3312))
#yextrema=(615,-332) # this one cuts the witch
yextrema=(380,-220)  # this one includes it
imgWidth=1656+138
imgHeight=2488-332-270


imgSlices=tuple((slice(yextrema[0], yextrema[1]),)+(slice(xextrema[i][0], xextrema[i][1]),) for i in range(2))
outSlices= ((slice(0,Parameters.no_boxes_2_y),slice(0,Parameters.no_boxes_2_x-14)),(slice(0,Parameters.no_boxes_2_y),slice(14,Parameters.no_boxes_2_x)))
compSlicesPos=((slice(0,Parameters.no_boxes_2_y),slice(0,Parameters.no_boxes_2_x-14)),(slice(0,Parameters.no_boxes_2_y),slice(Parameters.no_boxes_2_x-14, 2*(Parameters.no_boxes_2_x-14))))
compSlicesVel=((slice(0,Parameters.no_boxes_2_y),slice(0,Parameters.no_boxes_2_x)),(slice(0,Parameters.no_boxes_2_y),slice(Parameters.no_boxes_2_x-28, 2*(Parameters.no_boxes_2_x-14))))
# #Compile kernels and initialize variables (only needed once)
GPU = Cl_DPIV.compile_Kernels(thr)
Cl_DPIV.initialization(imgWidth, imgHeight, thr)
imgFiles=[]
saveFiles=[]



# see if offsets for composite image are already present
try:
    with open(dirCompositeImage+'/Offsets','rb') as fp:
        Offsets=pickle.load(fp)
    print("Offsets loaded from file")
    xO=np.array([_o[1] for _o in Offsets])
    yO=np.array([_o[0] for _o in Offsets])
    xAvgOffsets=tuple(round(_o) for _o in np.mean(xO,axis=0))
    yAvgOffsets=tuple(round(_o) for _o in np.mean(yO,axis=0))


    doOffsets=False
    useAvgOffsets=True

    print("avg x offsets", xAvgOffsets)
    print("avg y offsets", yAvgOffsets)
    
except:
    Offsets=[]
    print("Offsets not present")
    doOffsets=True
#=========================================================================================================
#SYNTETIC IMAGES TO PERFORM TEST
#=========================================================================================================
#Synt_Img.width=1024*3
#Synt_Img.height=1024*2
#SyIm.Analytic_Syntetic(dirImg, "Test_Img_")

#=========================================================================================================
#LIST OF IMAGES TO PROCESS
#=========================================================================================================
data=loadmat('Match.mat')
Match=data['Match'].copy()
del data

totFiles=[]
for n,(I,R) in enumerate(zip(dirImg,dirRes)):
    if not os.path.exists(I):
        os.makedirs(I)
    if not os.path.exists(R):
        os.makedirs(R)

    files = os.listdir(I)
    files = Tcl().call('lsort', '-dict', [i for i in files if i.endswith('.tif')])
    imgFiles.append([I+'/'+_f for _f in files])
    saveFiles.append([R+_f[0:13]+ format(int(i),'05d')+".mat" for i,_f in enumerate(files)])
    totFiles.append(len(files))
totFiles=min(totFiles)

saveCompositeFiles=[dirCompositeImage+format(int(i),'05d')+".mat" for i in range(totFiles)]


backgroundImg=[]
for n in range(3):

    backgroundImg.append(np.asarray(cv2.cvtColor(cv2.imread(imgFiles[n][0]),
        cv2.COLOR_BGR2GRAY)).astype(np.float32))





import matplotlib.pyplot as plt 
Pos=['r','c','l']
width=2*(Parameters.no_boxes_2_x-14)
height=Parameters.no_boxes_2_y
dy=round(imgHeight/height)
dx=round(2*imgWidth/width)

x=np.ones((height,1))*np.arange(width).reshape((1,width))

X=np.arange(Parameters.no_boxes_2_x)

blender=2*[[]]
blender[0]=(1-np.tanh(-((Parameters.no_boxes_2_x-X-14)/4)))/2
blender[1]=np.ones_like(blender[0])
blender[1][:28]=1-blender[0][-28:]


#=========================================================================================================
#PYTHON PROCESSING
#=========================================================================================================
#with Bar('Processing', max=totFiles-1) as bar:
print("Processing %05d files" % totFiles)
#Loop for load all images (only one in the example)
Offsets=[]
for i in tqdm(range(350,351,1), ascii=True): 
#for i in tqdm(range(totFiles), ascii=True): 
    
    comp={}
    
    for n in range(3):
        try:
            
            data=loadmat(saveFiles[n][Match[i,n]])
            u2=data['u']
            v2=data['v']
        except:
            x2=np.ones((height,1))*(np.arange(width).reshape(1,width))*dx
            y2=np.arange(height).reshape(height,1)*np.ones((1,width))*dy
            u2=np.zeros_like(y2)
            v2=np.zeros_like(u2)
            Img2= np.asarray(cv2.cvtColor(cv2.imread(imgFiles[n][Match[i,n]]),
                cv2.COLOR_BGR2GRAY)).astype(np.float32) #Load images
            
            for counter,(imgs,outs,compsPos,compsVel) in enumerate(zip(imgSlices,outSlices,compSlicesPos,compSlicesVel)):
                
                f1=backgroundImg[n][imgs].copy()
                f2=Img2[imgs].copy()
                # [x2, y2, CPUu2, CPUv2] = DPIV.processing(f1, f2)
                img1_gpu = thr.to_device(f1)
                img2_gpu = thr.to_device(f2)
            
                GPU = Cl_DPIV.processing(img1_gpu, img2_gpu, thr)
                
                
                # x2[comps] = GPU.x2.get()[outs]
                # y2[comps] = GPU.y2.get()[outs]
                # u2[comps] = GPU.u2_f.get()[outs]
                # v2[comps] = GPU.v2_f.get()[outs]
                #x2[compsPos] = GPU.x2.get()[outs]
                #y2[compsPos] = GPU.y2.get()[outs]
                u2[compsVel] += GPU.u2_f.get()*blender[counter]
                v2[compsVel] += GPU.v2_f.get()*blender[counter]
                # u2[compsVel] += CPUu2*blender[counter]
                # v2[compsVel] += CPUv2*blender[counter]
            # del GPU
            # break
            
            dic={"x2": x2, "y2" : y2, "u" : u2, "v" : v2}
            savemat(saveFiles[n][i], dic)
            if n==3:
                plt.imshow(v2**2+u2**2);plt.clim(0,55);plt.show()
        finally:
            comp.update({Pos[n]:(u2,v2)})
        # end of for over cameras
    
    
    
    vPad=10
    V=np.zeros((v2.shape[0]+2*vPad, 3*v2.shape[1]))
    U=np.zeros_like(V)
    yOffset=[]
    xOffset=[]
    if doOffsets:
        
        for n in range(2):
            VR=comp[Pos[n]][1]
            VL=comp[Pos[n+1]][1]
        
            err=[]

            nx=VL.shape[1]

            err=np.zeros((vPad,40))
            for ix in range(41,81):
                for ky in range(-vPad//2,vPad//2):
                    err[ky+vPad//2,ix-41]=(np.mean((VL[15:-15,nx-ix:]-VR[15+ky:-15+ky,0:ix])**2))
            ofst=np.where(err == np.amin(err))
            yOffset.append( ofst[0][0]-vPad//2)
            xOffset.append(ofst[1][0]+41)
        Offsets.append((yOffset,xOffset))
    else:
        if useAvgOffsets:
            yOffset,xOffset=yAvgOffsets,xAvgOffsets
        else:
            yOffset,xOffset=Offsets[i]
    
    leftBlender=(1-np.tanh(-((width-x-float(xOffset[1])/2)/10)))/2
    rightBlender=(1-np.tanh(-((x-float(xOffset[0])/2)/10)))/2
    centerBlender=np.ones_like(leftBlender)
    centerBlender*=(1-np.tanh(-((x-float(xOffset[1])/2)/10)))/2#leftBlender[:,::-1]
    centerBlender*=(1-np.tanh(-((width-x-float(xOffset[0])/2)/10)))/2#rightBlender[:,::-1] 
    
    try:

        V[vPad:vPad+height,:width]+=comp['l'][1][:,:]*leftBlender
        V[vPad-yOffset[1]:vPad+height-yOffset[1], width-xOffset[1]:2*width-xOffset[1]]+=comp['c'][1][:,:]*centerBlender
        V[vPad-sum(yOffset):vPad+height-sum(yOffset), 2*width-sum(xOffset):-sum(xOffset)]+=comp['r'][1][:,:]*rightBlender
        U[vPad:vPad+height,:width]+=comp['l'][0][:,:]*leftBlender
        U[vPad-yOffset[1]:vPad+height-yOffset[1], width-xOffset[1]:2*width-xOffset[1]]+=comp['c'][0][:,:]*centerBlender
        U[vPad-sum(yOffset):vPad+height-sum(yOffset), 2*width-sum(xOffset):-sum(xOffset)]+=comp['r'][0][:,:]*rightBlender
        
       
       
    except:
        print("file no. ", i, " returned at exception")
        V[...]=np.nan
        U[...]=np.nan
    finally:
        Slice=(slice(5,215),slice(9,851))
        dic={"u" : U[Slice].copy(), "v" : V[Slice].copy()}
        
        savemat(saveCompositeFiles[i],dic)
       
if doOffsets:
    with open(dirCompositeImage+'/Offsets', 'wb') as fp:
        pickle.dump(Offsets, fp)


    


print("OpenCl algorithm finished. Time = ", time.time()-start, "s")