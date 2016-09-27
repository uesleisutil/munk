;;; cfsr_latentevento.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 29 Jul 2015                                      ;
; Last modified  - 09 Nov 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

    load "/home/uesleisutil/NCL/loads.ncl"

; 1.2. Begin. 

  begin

  a   = addfile("/home/uesleisutil/Documentos/Artigo_monografia/Dados/cfsr_nov2008.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set time.                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  time         = a->time
  times        = cd_calendar(time, -3) ; YYYYMMDDHH
  times        = times-1
  ntimes       = dimsizes(times) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Time loop, workstation and print working on.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it             = 0,ntimes-1             ; TIME LOOP
  
  wks               = gsn_open_wks("png",times(it))
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed") ; For LH and SH
 ;gsn_define_colormap(wks,"NCV_jet") 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
  lsm   = a->LAND_L1(it,:,:)
  lh1   = a->LHTFL_L1(it,:,:)
  sh1   = a->SHTFL_L1(it,:,:)
  sst1  = a->TMP_L1(it,:,:)
  u     = a->U_GRD_L103(it,:,:)
  v     = a->V_GRD_L103(it,:,:)
  lon2d = a->lon
  lat2d = a->lat

  sst2  = sst1-273.15
  sst   = mask(sst2,lsm.ge.1,False)

  copy_VarCoords(sst1, sst)

  lh    = mask(lh1,lsm.ge.1,False)
  sh    = mask(sh1,lsm.ge.1,False)


 ; delete([/lh1,sst1,sh1,sst2/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Set global Resources                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  res                                    = True
  res@gsnFrame                           = False
  res@gsnDraw                            = False
  res@gsnLeftString                      = " "
  res@gsnRightString                     = " "
  res@gsnCenterString                    = " "
  res@gsnCenterStringOrthogonalPosF      = 0.01
  res@gsnAddCyclic                       = False
  ;res@tfDoNDCOverlay                     = True          ; Necessary for contours to be overlaid correctly on WRF projection
  res@tiXAxisString                      = " "
  res@tiYAxisString                      = " "
  res@tiMainString                       = times(it)
  res@sfXArray                           = lon2d 
  res@sfYArray                           = lat2d 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Set map Resources I                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  mpres                                  = True
  mpres                                  = res
  mpres@mpDataSetName                    = "Earth..4"          ; This new database contains
  mpres@mpDataBaseVersion                = "MediumRes"         ; Medium resolution database
  mpres@mpOutlineOn                      = True                ; Turn on map outlines
  mpres@mpDataBaseVersion                = "MediumRes"
  mpres@mpOutlineSpecifiers              = (/"Brazil:states"/)  
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
  mpres@mpGridAndLimbOn                  = True               ; Default is every 15 deg
  mpres@mpGridLatSpacingF                = 2
  mpres@mpGridLonSpacingF                = 2 
  mpres@tmXBTickSpacingF                 = 2
  mpres@tmYLTickSpacingF                 = 2
  mpres@mpMinLonF                        = -55.0             ; longitude oeste
  mpres@mpMaxLonF                        = -35.0             ; longitude leste
  mpres@mpMinLatF                        = -35.0             ; latitude sul
  mpres@mpMaxLatF                        = -20.0             ; latitude norte
  mpres@mpLandFillColor                  = "gray"            ; set land to be gray
  mpres@tmXBLabelFontHeightF             = 0.012        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Set LH contour Resources                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tf_res                                 = res
  tf_res@cnFillOn                        = True  
  tf_res@cnLinesOn                       = False 
  tf_res@cnLevelSelectionMode            = "ManualLevels"
  tf_res@cnLevelSpacingF                 = 3
  tf_res@cnMinLevelValF                  = 0
  tf_res@cnMaxLevelValF                  = 360
  tf_res@lbLabelFontHeightF              = 0.014
  tf_res@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res@lbTitleString                   = "Fluxo de Calor Latente (W m~S~-2~N~)" ; bar title
  tf_res@lbOrientation                   = "Horizontal"
  tf_res@lbTitleFontThicknessF           = 1
  tf_res@lbMinLabelSpacingF  = 2
  tf_res@pmLabelBarOrthogonalPosF        = 0.109
  tf_res@pmLabelBarParallelPosF          = 0.409
  tf_res@pmLabelBarWidthF                = 0.5
  tf_res@pmLabelBarHeightF               = 0.059 
 ;tf_res@cnFillPalette                   = "MPL_jet"
  contour_lh                             = gsn_csm_contour(wks,lh,tf_res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Set SH contour Resources                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tf_res2                                 = res
  tf_res2@cnFillOn                        = True  
  tf_res2@cnLinesOn                       = False 
  tf_res2@cnLevelSelectionMode            = "ManualLevels"
  tf_res2@cnLevelSpacingF                 = 1.2
  tf_res2@cnMinLevelValF                  = 0
  tf_res2@cnMaxLevelValF                  = 120
  tf_res2@lbLabelFontHeightF              = 0.014
  tf_res2@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res2@lbTitleString                   = "Fluxo de Calor Sens"+iacute+"vel (W m~S~-2~N~)" ; bar title
  tf_res2@lbOrientation                   = "Horizontal"
  tf_res2@lbTitleFontThicknessF           = 1
  tf_res2@pmLabelBarOrthogonalPosF        = 0.109
    tf_res2@pmLabelBarParallelPosF          = 0.409
  tf_res2@pmLabelBarWidthF                = 0.5
  tf_res2@pmLabelBarHeightF               = 0.059 
 ;tf_res@cnFillPalette                   = "MPL_jet"
  contour_sh                             = gsn_csm_contour(wks,sh,tf_res2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Set SST contour Resources                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tf_res3                                = res
  tf_res3@cnFillOn                       = True  
  tf_res3@cnLinesOn                      = False 
  tf_res3@cnLevelSelectionMode           = "ManualLevels"
  ;tf_res3@cnLevels                       = ispan(-14,30,1)
  tf_res3@cnLevelSpacingF                = 0.1
  tf_res3@cnMinLevelValF                 = 15
  tf_res3@cnMaxLevelValF                 = 25
  tf_res3@lbLabelFontHeightF             = 0.014
  tf_res3@lbTitleFontHeightF             = .015            ; make title smaller
  tf_res3@lbTitleString                  = "Temperatura da Superf"+iacute+"cie do Mar(~S~o~N~C)" ; bar titl
  tf_res3@lbOrientation                  = "Horizontal"
  tf_res3@lbTitleFontThicknessF          = 1
  tf_res3@lbLabelConstantSpacingF        = 1
  tf_res3@pmLabelBarOrthogonalPosF       = 0.109
  tf_res3@pmLabelBarWidthF               = 0.5
  tf_res3@pmLabelBarHeightF              = 0.059 
 ;tf_res@cnFillPalette                   = "MPL_jet"
  contour_sst                             = gsn_csm_contour(wks,sst,tf_res3)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 10. Set Wind contour line Resources                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 10.1. Vector resources.

; 10.1.1. Vector Global resources

  vcres                              = res         
  vcres@vcGlyphStyle                 = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF               = 0.030            ; thin out vectors
  vcres@vcLineArrowThicknessF        = 4
  ;vcres@vcMinFracLengthF            = 1                 ; "Broken vector"

; 10.1.2. If Coloured Vectors 

  vcres@gsnFrame                     = False
  vcres@gsnDraw                      = False
  vcres@vcMonoLineArrowColor         = True
  vcres@vcMonoFillArrowFillColor     = True

  vcres@lbLabelFontHeightF           = 0.014
  vcres@lbTitleFontHeightF           = .015            ; make title smaller
  vcres@lbTitleString                = "Vento a 10 m (m s~S~-1~N~) " ; bar title
  vcres@lbOrientation                = "Horizontal"
  vcres@pmLabelBarOrthogonalPosF     = 0.139
  vcres@pmLabelBarWidthF             = 0.5
  vcres@pmLabelBarHeightF            = 0.059 
  vcres@vcLevelSelectionMode         = "ExplicitLevels"
  vcres@vcLevels                     = ispan(0,10,1)
  vcres@vcLineArrowColor        = "Black"           ; change vector color
; 10.1.3. If Reference Vector

  vcres@vcRefAnnoOn                  = True
  vcres@vcRefAnnoSide                = "Top"
  vcres@vcRefAnnoString2On           = False
  vcres@vcRefAnnoPerimOn             = True
  vcres@vcRefAnnoOrthogonalPosF      = -1.240
  vcres@vcRefAnnoParallelPosF        = 1.00
  vcres@vcRefMagnitudeF              = 10 
  vcres@vcRefAnnoString1             = "Vento (m s~S~-1~N~)"
  vcres@vcRefAnnoBackgroundColor     = "White"
  vcres@vcRefLengthF                 = 0.03             ; reference vector length
  vcres@vcRefAnnoArrowUseVecColor    = False

; 10.1.4. Create vector

  vcres@vcVectorDrawOrder            = "PostDraw"
  vector_w                           = gsn_csm_vector(wks,u,v,vcres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 11. Set map Resources II                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mpres@gsnFrame                         = False
  mpres@gsnDraw                          = False
  mpres                                  = wrf_map_resources(a,mpres)
  map                                    = gsn_csm_map(wks,mpres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 12. Overlay plots on map and draw                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  overlay(map,contour_sst) 
  ;overlay(map,vector_w)

  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 
  end do
  end