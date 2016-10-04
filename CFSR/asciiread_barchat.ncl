;;; asciiread_barchart.ncl ;;;;;;;;.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 04 Oct 2016                                      ;
; Last modified  - 04 Oct 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "/home/uesleisutil/NCL/loads.ncl"
begin

ncol  = 8
ntim  = numAsciiRow("/home/uesleisutil/Documentos/correl2.csv")
a = asciiread("/home/uesleisutil/Documentos/correl2.csv",(/ntim,ncol/),"float")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dia           = a(:,0)
pomerode      = a(:,1)
timbo         = a(:,2)
riodoscedros  = a(:,3)
majorgercino  = a(:,4)
angelina      = a(:,5)
fcl           = a(:,6)
tsm           = a(:,7)

y             = majorgercino
x             = dia
cidade        = "Rio dos Cedros"

wks   = gsn_open_wks ("png", "bar" )  ; send graphics to PNG file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Set resources.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 3.1. Bar chart resources
res                            = True
res@gsnScale                   = False               
res@vpXF                       = 0.10        ; In page coordinates, where to start
res@vpYF                       = 0.75        ; the plot
res@vpHeightF                  = 0.43        ; Changes the aspect ratio
res@vpWidthF                   = 0.85
res@tmXBMinorOn                = False ; turn off minor tickmarks
res@tmYLMinorOn                = False
res@tmXTOn                     = True ; turn off top tickmarks
res@tmYROn                     = False ; turn off right tickmarks
res@tmXTBorderOn               = True ; turn off top axis
res@tmYRBorderOn               = False ; turn off right axis
res@gsnXYBarChart              = True
res@gsnXYBarChartBarWidth      = 0.5           ; change bar widths
res@tmYLLabelFontHeightF       = 0.02 
res@tmXBLabelFontHeightF       = 0.02 
res@tiXAxisFontHeightF         = 0.02
res@tiYAxisFontHeightF         = 0.02
res@trYMinF                    = 0         
res@trYMaxF                    = 320      
res@vpWidthF                   = 0.7
res@vpHeightF                  = 0.5
res@vpXF                       = .15   
res@tiMainString               = cidade 
res@gsnYRefLine                = 0.              ; reference line   
res@gsnAboveYRefLineColor      = "Blue"           ; above ref line fill red
res@gsnBelowYRefLineColor      = "blue"          ; below ref line fill blue
res@tiYAxisString              = "Precipita"+cedil+""+atilde+"o (mm/24h)"
res@tiXAxisString              = "Dias"


plot = gsn_csm_xy (wks,x,y,res)


; 3.2. XY resources
  getvalues plot
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

xyres                    = True
xyres@vpXF               = vpx
xyres@vpYF               = vpy
xyres@vpWidthF           = vpw
xyres@vpHeightF          = vph
xyres@tmXBMinorOn        = False ; turn off minor tickmarks
xyres@tmXTMinorOn        = False ; turn off minor tickmarks
xyres@tmYLMinorOn        = False
xyres@tmXTOn             = False ; turn off top tickmarks
xyres@tmXBOn             = False ; turn off top tickmarks
xyres@tmYLOn             = False ; turn off right tickmarks
xyres@tmXTBorderOn       = False ; turn off top axis
xyres@tmXBBorderOn       = False ; turn off top axis
xyres@tmYLBorderOn       = False ; turn off right axis
xyres@xyLineThicknessF   = 5.0               ; default is 1.0
xyres@xyLineColor        = "Red"
xyres@tmYROn             = True
xyres@tmYRLabelsOn       = True
xyres@tmYRBorderOn       = True ; turn off right axis
xyres@tiYAxisString      = "Fluxo de Calor Latente (W/m~S~2~N~)"
xyres@tiYAxisSide        = "Right"
xyres@tiYAxisAngleF      = 270              ; Rotate the Y-axis title 270 degrees
xyres@tiXAxisFontHeightF = 0.02
xyres@tiYAxisFontHeightF = 0.02
xy_plot = gsn_csm_xy (wks,x,fcl,xyres)

anno_id          = gsn_add_annotation(plot, xy_plot, False)
pres             = True
pres@gsnMaximize = True
maximize_output(wks,pres)

end

