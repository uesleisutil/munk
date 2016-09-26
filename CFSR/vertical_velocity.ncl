;;; vertical_velocity.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 08 Jul 2015                                      ;
; Last modified  - 08 Jul 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin.
  
begin

do it=0,50

dir  = "/home/daniela/Documents/Dissertação/Dados"
f    = addfile(dir + "/cfsr_latentevento.nc","r")

v    = f->V_GRD_L100(it,:,:,:)
w    = f->V_VEL_L100(it,:,:,:)

w1 = 50.0 * w         ; The variable "w" is much smaller than "v", so it  is multiplied by 100.

w!0            = "lev"                    
w!1            = "lat"                     
w!2            = "lon"                     
;w!3            = "lon"                     
w1!0           = "lev"                    
w1!1           = "lat"                   
w1!2           = "lon"                     
; w1!3           = "lon"                     
     
copy_VarCoords(w,w1)

w@units        = "hpa"
w&lev@units    = "hpa"
w1@units       = "hpa"
w1&lev@units   = "hpa"

printMinMax (v,True)
printMinMax (w,True)
printMinMax (w1,True)

wks = gsn_open_wks("png","cfsr"+it)

gsn_define_colormap(wks,"temp_diff_18lev")

 res                          = True
 res@cnLinesOn                = False
 res@cnFillOn                 = True
 res@vcRefLengthF             = 0.04
 res@vcGlyphStyle             = "CurlyVector"          
 res@vcRefAnnoOn              = True           
 res@vcRefAnnoOrthogonalPosF  = 0.0
 res@vcRefAnnoParallelPosF    = 0.6     
 res@vcLineArrowThicknessF    = 5
 res@vcRefAnnoString2On       = False   
 res@vcRefAnnoPerimOn         = True     
 res@vcMinDistanceF           = 0.03  
 res@vcRefMagnitudeF          = 15.0               ; Reference vector magnitude
 res@vcRefAnnoString1         = "Vento: 15 m s~S~-1~N~"
 ;res@vcMinFracLengthF         = 1                 ; "Broken vector"
 res@cnLevelSelectionMode     = "ManualLevels"
 res@cnLevelSpacingF          =  0.059
 res@cnMinLevelValF           = -1.09
 res@cnMaxLevelValF           =  1.09
 res@lbLabelStride             = 1
 res@lbLabelAngleF            = 90.0

zi  = 1000 ; first level
zf  = 300  ; last level 
lon = 300  ; longitude

plot = gsn_csm_pres_hgt_vector(wks,w({zi:zf},{-37.5},:),v({zi:zf},{-37.5},:),w1({zi:zf},{-37.5},:),res)  

end do

end
