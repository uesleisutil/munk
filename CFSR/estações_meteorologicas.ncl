;;; estacoes_meteorologicas.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 03 Oct 2016                                      ;
; Last modified  - 03 Oct 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "/home/uesleisutil/NCL/loads.ncl"
begin
 
a = addfile("/home/uesleisutil/Documentos/cfsr_correl.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Time loop, workstation and print working on.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wks               = gsn_open_wks("png","teste")
gsn_define_colormap(wks,"NCV_jet") ; For LH and SH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
it = 88 
lsm   = a->LAND_L1(it,:,:)
lh1   = a->LHTFL_L1(it,:,:)
lon2d = a->lon
lat2d = a->lat
lh1   = mask(lh1,lsm.ge.1,False)
wks   = gsn_open_wks("png","draw_order")
gsn_define_colormap(wks,"WhBlGrYeRe")         ; choose colormap
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set global resources.                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
res                          = True
res@gsnDraw                  = False
res@gsnFrame                 = False
res@gsnAddCyclic             = False   ; Don't add longitude cyclic pt.
res@mpOutlineOn              = True
res@cnFillOn                 = True              ; color plot desired
res@pmTickMarkDisplayMode    = "Always" ; display tick marks
res@tmXTLabelsOn             = False ; turn off tick-marks labels at top of plot
res@tmYRLabelsOn             = False ; trun off tick-marks labels at right of plot
res@mpGridAndLimbOn          = True ; set to true if you want grid lines to show
res@mpGridLineDashPattern    = 2 ; make grid lines dash
res@mpGridLineColor          = "black" ; grid line color black
res@cnLevelSpacingF          = 5
res@cnMinLevelValF           = 120
res@cnMaxLevelValF           = 400
res@cnLinesOn                = False 
res@cnLevelSelectionMode     = "ManualLevels"
res@cnFillPalette            = "MPL_jet"
res@lbLabelFontHeightF       = 0.014
res@lbTitleFontHeightF       = .015            ; make title smaller
res@lbTitleString            = "Fluxo de Calor Latente (W/m~S~2~N~)" ; bar title
res@lbOrientation            = "Horizontal"
res@lbTitleFontThicknessF    = 1
res@lbMinLabelSpacingF       = 2
res@pmLabelBarOrthogonalPosF = 0.109
res@pmLabelBarParallelPosF   = 0.409
res@pmLabelBarWidthF         = 0.5
res@pmLabelBarHeightF        = 0.059 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Set map resources.                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mpres                             = res
mpres@mpDataSetName               = "Earth..4"          ; This new database contains
mpres@mpDataBaseVersion           = "MediumRes"         ; Medium resolution database
mpres@mpOutlineOn                 = True                ; Turn on map outlines
mpres@mpDataBaseVersion           = "MediumRes"
mpres@mpOutlineSpecifiers         = (/"Brazil:states"/)  
mpres@mpProvincialLineColor       = "black"             ; States line color line
mpres@mpGeophysicalLineColor      = "black"             ; Contour map color line
mpres@mpNationalLineColor         = "black"             ; Continent  olor line
mpres@pmLegendOrthogonalPosF      = -0.99               ; Wind legend localization
mpres@pmLegendParallelPosF        = 1.0                 ; Wind legend localization
mpres@mpProvincialLineThicknessF  = 3                   ; State line thickness  
mpres@mpNationalLineThicknessF    = 3                   ; Continent line thickness
mpres@mpGeophysicalLineThicknessF = 3.0 
mpres@mpPerimOn                   = True
mpres@mpPerimLineThicknessF       = 3.0
mpres@mpGridAndLimbOn             = True               ; Default is every 15 deg
mpres@mpGridLatSpacingF           = 2
mpres@mpGridLonSpacingF           = 2 
mpres@tmXBTickSpacingF            = 2
mpres@tmYLTickSpacingF            = 2
mpres@mpMinLonF                   = -50.0             ; longitude oeste
mpres@mpMaxLonF                   = -43.0             ; longitude leste
mpres@mpMinLatF                   = -31.0             ; latitude sul
mpres@mpMaxLatF                   = -25.0             ; latitude norte
mpres@mpLandFillColor             = "tan"            ; set land to be gray
mpres@tmXBLabelFontHeightF        = 0.012        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Plot and set polymakers and polylines resources                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
plot = gsn_csm_contour_map(wks,lh1,mpres)

; 7.1. Angelina
mpres@gsMarkerIndex    = 1
mpres@gsMarkerColor    = "blue"       ;-- marker color
mpres@gsMarkerSizeF    =  0.06        ;-- set size of marker
mpres@gsLineThicknessF =  4.0          ;-- marker line thickness
str                    = unique_string("poly")            ;-- result is poly0-poly15
plot@$str$             = gsn_add_polymarker(wks, plot, -49.0558, -27.5389, mpres) 
    
; Major Gercino                              
mpres@gsMarkerIndex    = 1
mpres@gsMarkerColor    = "green"       ;-- marker color
mpres@gsMarkerSizeF    =  0.06        ;-- set size of marker
mpres@gsLineThicknessF =  4.0          ;-- marker line thickness
str                    = unique_string("poly")            ;-- result is poly0-poly15
plot@$str$             = gsn_add_polymarker(wks, plot, -48.9648, -27.3568, mpres) 

; Rio dos Cedros                              
mpres@gsMarkerIndex    = 1
mpres@gsMarkerColor    = "yellow"       ;-- marker color
mpres@gsMarkerSizeF    =  0.06        ;-- set size of marker
mpres@gsLineThicknessF =  4.0          ;-- marker line thickness
str                    = unique_string("poly")            ;-- result is poly0-poly15
plot@$str$             = gsn_add_polymarker(wks, plot, -49.2731, -26.7042, mpres) 

; Timbo                              
mpres@gsMarkerIndex    = 1
mpres@gsMarkerColor    = "black"       ;-- marker color
mpres@gsMarkerSizeF    =  0.06        ;-- set size of marker
mpres@gsLineThicknessF =  4.0          ;-- marker line thickness
str                    = unique_string("poly")            ;-- result is poly0-poly15
plot@$str$             = gsn_add_polymarker(wks, plot, -49.2550, -26.9308, mpres) 

; Polyline resources
ypts                   = (/ -30.0,  -30.0,  -26,   -26, -30.0/)
xpts                   = (/-48, -44.0,-44.0, -48.0,-48.0/)
plres                  =  True
plres@gsLineThicknessF =  8.0        ;-- set line thickness
plres@gsLineColor      = "black"       ;-- set line color
box_1                  = gsn_add_polyline(wks, plot, xpts, ypts, plres)  ;-- add polyline to map

draw(plot)
frame(wks)
end