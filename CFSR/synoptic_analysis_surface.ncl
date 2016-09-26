;;; synoptic_analysis_surface.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 29 Jul 2015                                      ;
; Last modified  - 29 Nov 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

; 1.1. Prototype scripts.

  load "/home/uesleisutil/NCL/loads.ncl"

; 1.2. Begin. 

  begin

  f   = addfile("/home/uesleisutil/Documentos/diss/cfsr/cfsr_sup.nc","r")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Time loop, workstation and print working on.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  do it             = 0,29            ; TIME LOOP
  wks               = gsn_open_wks("png","./cfsr_sup/sup_"+it)
  gsn_define_colormap(wks,"cmp_b2r") 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
  u     = f->U_GRD_L103(it,:,:)
  v     = f->V_GRD_L103(it,:,:)
  t     = f->PRES_L101(it,:,:)
  t1    = t/100
  copy_VarCoords(t, t1)

  temp1 = f->TMP_L103(it,:,:)
  temp  = temp1-273.15
  copy_VarCoords(temp1, temp)
  wrf_smooth_2d(t1, 20)


  time         = f->time
  times        = cd_calendar(time, -3) ; YYYYMMDDHH
  times        = times-1
  ntimes       = dimsizes(times) 

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
  res@gsnAddCyclic                       = False
  res@tfDoNDCOverlay                     = True          ; Necessary for contours to be overlaid correctly on WRF projection
  res@tiXAxisString                      = " "
  res@tiYAxisString                      = " "
  res@tiMainString                       = times(it)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Set map Resources I                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  mpres                                  = True
  mpres                                  = res
  mpres@mpDataSetName                    = "Earth..4"          ; This new database contains
  mpres@mpDataBaseVersion                = "MediumRes"         ; Medium resolution database
  mpres@mpOutlineOn                      = True                ; Turn on map outlines
  mpres@mpDataBaseVersion                = "MediumRes"
  mpres@mpOutlineSpecifiers              = (/"Brazil:states"/)  
  mpres@mpGridAndLimbOn                  = True               ; Default is every 15 deg
  mpres@mpGridLatSpacingF                = 15
  mpres@mpGridLonSpacingF                = 15 
  mpres@mpProvincialLineColor            = "black"             ; States line color line
  mpres@mpGeophysicalLineColor           = "black"             ; Contour map color line
  mpres@mpNationalLineColor              = "black"             ; Continent  olor line
  mpres@pmLegendOrthogonalPosF           = -0.99               ; Wind legend localization
  mpres@pmLegendParallelPosF             = 1.0                 ; Wind legend localization
  mpres@mpProvincialLineThicknessF       = 3                   ; State line thickness  
  mpres@mpNationalLineThicknessF         = 3                   ; Continent line thickness
  mpres@mpGeophysicalLineThicknessF      = 3.0 
  mpres@mpPerimOn                        = True
  mpres@mpPerimLineThicknessF            = 3.0
  mpres@mpMinLonF                        = -85.0               ; longitude oeste
  mpres@mpMaxLonF                        = -25.0               ; longitude leste
  mpres@mpMinLatF                        = -60.0               ; latitude sul
  mpres@mpMaxLatF                        = 15.0               ; latitude norte
  mpres@tmXBTickSpacingF                 = 15
  mpres@tmYLTickSpacingF                 = 15

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Set SST contour Resources                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tf_res                                 = res
  tf_res@cnFillOn                        = True  
  tf_res@cnLinesOn                       = False 
  tf_res@cnLevelSelectionMode            = "ManualLevels"      ; set manual contour levels
  tf_res@cnMinLevelValF                  = -10.                  ; set min contour level
  tf_res@cnMaxLevelValF                  = 30.                 ; set max contour level
  tf_res@cnLevelSpacingF                 = 0.5                   ; set contour spacing
  ;tf_res@cnLevelSpacingF = 1


  tf_res@lbTitleFontHeightF              = .015                    
  tf_res@lbOrientation                   = "Vertical"
  tf_res@lbTitleFontThicknessF           = 1

  contour_lh                             = gsn_csm_contour(wks,temp,tf_res)


  levels                                 = ispan(950,1050,3)
  slp_res                                = res
  slp_res@cnLineColor                    = "Blue"
  slp_res@cnLevelSelectionMode           = "ExplicitLevels"
  slp_res@cnLevels                       = levels
 ; slp_res@cnLineLabelBackgroundColor     = -1    ; transparent
  slp_res@cnLineLabelPerimThicknessF     = 4
  slp_res@cnLineThicknessF               = 2.5
  slp_res@cnHighLabelsOn                 = True
  slp_res@cnLowLabelsOn                  = True
  slp_res@cnHighLabelBackgroundColor     = -1
  slp_res@cnLowLabelBackgroundColor      = -1
  slp_res@cnInfoLabelString              = " "
  slp_res@cnInfoLabelOrthogonalPosF      = 0.237
  slp_res@cnInfoLabelParallelPosF        = 0.79
  slp_res@cnInfoLabelFontColor           = "Black"
  slp_res@cnInfoLabelPerimOn             = False   
  slp_res@cnHighLowLabelOverlapMode      = "OmitOverVPAndHL"
  contour_psl                            = gsn_csm_contour(wks,t1,slp_res)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Set SLP contour line Resources                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 4.4. Vector resources.

; 4.4.1. Vector Global resources

  vcres                             = res         
  vcres@vcGlyphStyle                = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF              = 0.045            ; thin out vectors
  vcres@vcLineArrowThicknessF       = 4
  vcres@vcRefAnnoOn                 = True
  vcres@vcRefAnnoSide               = "Bottom"

  vcres@vcMonoLineArrowColor        = True   ; color arrows based on magnitude
  vcres@vcMinFracLengthF            = 0.9
  vcres@vcLevelPalette              = "WhiteBlueGreenYellowRed" ; set color map
  vcres@vcLevelSelectionMode        = "ExplicitLevels"
  vcres@vcLevels                    = ispan(0,80,1)

  ;vcres@pmLabelBarDisplayMode       = "Always"          ; Turn on a label bar.
  vcres@pmLabelBarWidthF            = 0.38              ; make it thinner
  vcres@pmLabelBarHeightF           = 0.05
  vcres@lbPerimOn                   = False             ; no box around it
  vcres@pmLabelBarParallelPosF      = 0.
  vcres@pmLabelBarOrthogonalPosF    = 0.1
  vcres@lbLabelFontHeightF          = 0.014

  vcres@vcRefAnnoString2On          = True
  vcres@vcRefAnnoPerimOn            = True
  vcres@vcRefAnnoOrthogonalPosF     = -1.249
  vcres@vcRefAnnoParallelPosF       = 1.0
  vcres@vcRefLengthF                = 0.050             ; reference vector length
  vcres@vcRefMagnitudeF             = 10
  vcres@vcRefAnnoFontThicknessF     = 1
  vcres@vcRefAnnoString1            = "10 m/s"
  vcres@vcRefAnnoBackgroundColor    = "White"

; 4.4.4. Create vector

  vcres@vcVectorDrawOrder           = "PostDraw"
  vector_w                          = gsn_csm_vector(wks,u,v,vcres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 10. Set map Resources II                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mpres@gsnFrame                         = False
  mpres@gsnDraw                          = False
  mpres                                  = wrf_map_resources(f,mpres)
  map                                    = gsn_csm_map(wks,mpres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 11. Overlay plots on map and draw                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  overlay(map,contour_lh) 

  overlay(map,vector_w)
  overlay(map,contour_psl) 
  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 
  end do
  end