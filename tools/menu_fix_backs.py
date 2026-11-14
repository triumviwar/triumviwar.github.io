# The clock soldiers backs on the main menu painting (round 3, art/menu_fix/NOTES.md): python3 tools/menu_fix_backs.py IN.png OUT.png
import cv2,numpy as np,sys
im=cv2.imread(sys.argv[1]).astype(np.float32)
g=cv2.imread('art/menu_fix/r2_clock_right_gpt.png').astype(np.float32)
P=g[605:705,668:768].copy()
P[:,92:]=P[:,7::-1][:, :8]          # the blue shoulder at the right edge -> mirrored red
hp=cv2.cvtColor(np.clip(P,0,255).astype(np.uint8),cv2.COLOR_BGR2HSV)
pred=((hp[...,0]<8)|(hp[...,0]>170))&(hp[...,1]>110)
pmean=P[pred].mean(0)
D=[(1380,490,9),(1296,512,6.5),(1337,502,5),(1267,582,11),(1418,653,11.5),(1489,609,8),(1623,577,9),(1381,736,17)]
H,W=im.shape[:2]
hsv=cv2.cvtColor(im.astype(np.uint8),cv2.COLOR_BGR2HSV)
yy,xx=np.mgrid[0:H,0:W]
for cx,cy,r in D:
    R=r*1.02; n=int(np.ceil(R*2))+2
    q=cv2.resize(P,(n,n),interpolation=cv2.INTER_AREA)
    d=np.hypot(xx-cx,yy-cy)
    rim=(d<r*1.4).astype(np.uint8)
    u=cv2.inpaint(np.clip(im,0,255).astype(np.uint8),rim,3,cv2.INPAINT_TELEA).astype(np.float32)
    rb=np.clip((r*1.4-d)/1.0,0,1)*np.clip((d-r*0.85)/1.0,0,1)
    im=im*(1-rb[...,None])+u*rb[...,None]
    ann=(d>r*1.25)&(d<r*2.0)&((hsv[...,0]<8)|(hsv[...,0]>170))&(hsv[...,1]>120)
    loc=np.median(im[ann],0) if ann.sum()>5 else pmean
    q=q*float(loc.mean()/pmean.mean())
    x0=int(round(cx-n/2)); y0=int(round(cy-n/2))
    ly,lx=np.mgrid[0:n,0:n]; dd=np.hypot(lx+x0-cx,ly+y0-cy)
    a=np.clip((r*0.97-dd)/1.2,0,1)[...,None]
    reg=im[y0:y0+n,x0:x0+n]
    reg[:]=reg*(1-a)+q*a
cv2.imwrite(sys.argv[2],np.clip(im,0,255).astype(np.uint8))
