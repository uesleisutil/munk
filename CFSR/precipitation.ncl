;;; precipitation.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 29 Jul 2015                                      ;
; Last modified  - 02 Nov 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts and begin.                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin. 

  begin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Time loop, workstation and open directory.                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
; 2.1. Do.

  do it             = 0,30          

; 2.2. Workstation.

  wks               = gsn_open_wks("png","latente_"+it)
  gsn_define_colormap(wks,"MPL_jet") 

; 2.3. Open directory.

  dir = "/home/daniela/Documents/Dissertação/Dados"
  a   = addfile(dir + "/cfsr_prec2.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tc1 = a->PRATE_L1_Avg_1(it,:,:)
  tc2 = tc1*86400*1000
  tc3 = tc2/1000
  tc  = tc3/6
  copy_VarCoords(tc1, tc)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set global Resources                                           ;
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
; 5. Set map Resources I                                            ;
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
; 6. Set Precipitation contour Resources                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tf_res                                 = res
  tf_res@cnFillOn                        = True  
  tf_res@cnLinesOn                       = False 
  tf_res@cnLevelSelectionMode            = "ExplicitLevels"
  tf_res@cnLevels                        = ispan(0,25,1)
  tf_res@lbLabelFontHeightF              = 0.014
  tf_res@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res@lbTitleString                   = "Precipita"+cedil+""+atilde+"o (mm/h)" ; bar title
  tf_res@lbOrientation                   = "Horizontal"
  tf_res@lbTitleFontThicknessF           = 1
  tf_res@pmLabelBarOrthogonalPosF        = 0.109
  tf_res@pmLabelBarWidthF                = 0.5
  tf_res@pmLabelBarHeightF               = 0.059 
  contour_tc                             = gsn_csm_contour(wks,tc,tf_res)

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

  overlay(map,contour_tc) 


  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 
  end do
  
  end