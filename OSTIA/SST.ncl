;;; SST.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 04 Nov 2015                                      ;
; Last modified  - 05 Jul 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

  load "/home/uesleisutil/NCL/loads.ncl"

; 1.2. Begin. 

  begin

; 1.3. Do.

  do it             = 0,1          

; 1.4. Workstation.

  wks               = gsn_open_wks("png","tsm"+it)
  gsn_define_colormap(wks,"NCV_jet") 
; 1.5. Open file.

  a   = addfile("/home/uesleisutil/Documentos/Dissertação/Dados/oisst.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ostia
  ;temp1 = short2flt(a->analysed_sst(:,{0:-60},{-70:-25}))
  temp1 = a->sst(:,{0:-60},{290:335})
  temp  = temp1-273.15
  
  copy_VarCoords(temp1, temp)

  media = dim_avg_n_Wrap(temp, 0)
printVarSummary(media)

 setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize" : 300000000
 end setvalues

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Set global Resources                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  res                                    = True
  res@gsnFrame                           = False
  res@gsnDraw                            = False
  res@gsnLeftString                      = " "
  res@gsnRightString                     = " "
  res@gsnCenterString                    = " "
  res@gsnCenterStringOrthogonalPosF      = 0.01
  ;res@tfDoNDCOverlay                     = True          ; Necessary for contours to be overlaid correctly on WRF projection

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Set map Resources I                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  mpres                                  = True
  mpres                                  = res
  mpres@mpDataSetName                    = "Earth..4"     ; This new database contains
  mpres@mpDataBaseVersion                = "MediumRes"    ; Medium resolution database
  mpres@mpOutlineOn                      = True           ; Turn on map outlines
  mpres@mpDataBaseVersion                = "MediumRes"
  mpres@mpOutlineSpecifiers              = (/"Brazil:states"/)  
  mpres@mpGridAndLimbOn                  = False          ; Default is every 15 deg
  mpres@mpProvincialLineColor            = "black"        ; States line color line
  mpres@mpGeophysicalLineColor           = "black"        ; Contour map color line
  mpres@mpNationalLineColor              = "black"        ; Continent  olor line
  mpres@pmLegendOrthogonalPosF           = -0.99          ; Wind legend localization
  mpres@pmLegendParallelPosF             = 1.0            ; Wind legend localization
  mpres@mpProvincialLineThicknessF       = 3              ; State line thickness  
  mpres@mpNationalLineThicknessF         = 3              ; Continent line thickness
  mpres@mpGeophysicalLineThicknessF      = 3.0
  mpres@mpPerimOn                        = True
  mpres@mpPerimLineThicknessF            = 3.0
  mpres@mpMinLonF                        = -65.0             ; longitude oeste
  mpres@mpMaxLonF                        = -25.0             ; longitude leste
  mpres@mpMinLatF                        = -50.0             ; latitude sul
  mpres@mpMaxLatF                        = -15.0             ; latitude norte


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Set SST contour Resources                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tf_res                                 = res
  tf_res@cnFillOn                        = True  
  tf_res@cnLinesOn                       = False 
  tf_res@cnLevelSelectionMode            = "ManualLevels"
  tf_res@cnMinLevelValF                  = 3.                 ; set min contour level
  tf_res@cnMaxLevelValF                  = 25.                 ; set max contour level
  tf_res@cnLevelSpacingF                 = 0.5                   ; set contour spacing
  tf_res@lbLabelFontHeightF              = 0.014
  tf_res@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res@lbTitleString                   = " " ; bar title
  tf_res@lbOrientation                   = "Horizontal"
  tf_res@lbTitleFontThicknessF           = 1
  tf_res@pmLabelBarOrthogonalPosF        = 0.109
  tf_res@pmLabelBarWidthF                = 0.5
  tf_res@pmLabelBarHeightF               = 0.059 
  ;tf_res@FieldTitle                      = " "           ; overwrite Field Title
 ; tf_res@cnFillPalette                   = "MPL_jet"
  contour_temp                           = gsn_csm_contour(wks,media,tf_res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 10. Set map Resources II                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mpres@gsnFrame                         = False
  mpres@gsnDraw                          = False
  mpres                                  = wrf_map_resources(a,mpres)
  map                                    = gsn_csm_map(wks,mpres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 11. Overlay plots on map and draw                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  overlay(map,contour_temp) 
  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 
  end do
  
  end

