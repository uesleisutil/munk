;;; sst_pressure_wind.ncl ;;;...;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 04 Nov 2015                                      ;
; Last modified  - 08 Apr 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin. 

  begin

; 1.3. Do.

  do it             = 0,60          

; 1.4. Workstation.

  wks               = gsn_open_wks("png","tsmpressao"+it)
  ;gsn_define_colormap(wks,"MPL_rainbow") 

; 1.5. Open file.

  a = addfile("/home/daniela/Documents/Dissertação/Dados/cfsr_tpuv.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  temp = a->TMP_L1(it,:,:)
  ;lsm  = a->LAND_L1(it,:,:)
  p1    = a->PRES_L1(it,:,:)
  p = p1/100

  tc   = temp-272.15 ; K to C
  u     = a->U_GRD_L103(it,:,:)
  v     = a->V_GRD_L103(it,:,:)
 ;p    = mask(p2,lsm.ge.1,False)
  copy_VarCoords(temp, tc)
  copy_VarCoords(p1, p)

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
  tf_res@cnLevelSelectionMode            = "ExplicitLevels"
  tf_res@cnLevels                        = ispan(2,26,1)
  tf_res@lbLabelFontHeightF              = 0.014
  tf_res@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res@lbTitleString                   = "Temperatura do Ar 2m (~S~o~N~C)" ; bar title
  tf_res@lbOrientation                   = "Horizontal"
  tf_res@lbTitleFontThicknessF           = 1
  tf_res@pmLabelBarOrthogonalPosF        = 0.109
  tf_res@pmLabelBarWidthF                = 0.5
  tf_res@pmLabelBarHeightF               = 0.059 
  tf_res@FieldTitle                      = " "           ; overwrite Field Title
 ; tf_res@cnFillPalette                   = "MPL_jet"
  contour_tc                             = gsn_csm_contour(wks,tc,tf_res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Set SLP contour line Resources                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  levels                                 = ispan(950,1050,5)
  info_string                            = "Press"+atilde+"o ao n"+iacute+"vel do mar de 900 a 1100 por 4"
  slp_res                                = res
  slp_res@cnLineColor                    = "NavyBlue"
  slp_res@cnLevelSelectionMode           = "ExplicitLevels"
  slp_res@cnLevels                       = levels
  slp_res@cnLineLabelBackgroundColor     = -1    ; transparent
  slp_res@cnLineThicknessF               = 3.5
  slp_res@cnHighLabelsOn                 = True
  slp_res@cnLowLabelsOn                  = True
  slp_res@cnHighLabelBackgroundColor     = -1
  slp_res@cnLowLabelBackgroundColor      = -1
  slp_res@cnInfoLabelString              = info_string
  slp_res@cnInfoLabelOrthogonalPosF      = 0.237
  slp_res@cnInfoLabelParallelPosF        = 0.79
  slp_res@cnInfoLabelFontColor           = "Black"
  slp_res@cnInfoLabelPerimOn             = False   
  slp_res@cnHighLowLabelOverlapMode      = "OmitOverVPAndHL"
  contour_psl                            = gsn_csm_contour(wks,p,slp_res)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Set Wind contour line Resources                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 4.4. Vector resources.
  vcres                              = res         
  vcres@vcGlyphStyle                 = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF               = 0.030            ; thin out vectors
  vcres@vcLineArrowThicknessF        = 4
  ;vcres@vcMinFracLengthF            = 1                 ; "Broken vector"


  vcres@gsnFrame                     = False
  vcres@gsnDraw                      = False
  cres@vcMonoLineArrowColor         = True
  vcres@vcMonoFillArrowFillColor     = False
  vcres@lbLabelFontHeightF           = 0.014
  vcres@lbTitleFontHeightF           = .015            ; make title smaller
  vcres@lbTitleString                = "Vento 10 m (m s~S~-1~N~) " ; bar title
  vcres@lbOrientation                = "Horizontal"
  vcres@pmLabelBarOrthogonalPosF     = 0.139
  vcres@pmLabelBarWidthF             = 0.5
  vcres@pmLabelBarHeightF            = 0.059 
  vcres@vcLevelSelectionMode         = "ExplicitLevels"
  vcres@vcLevels                     = ispan(0,10,1)

; 4.4.3. If Reference Vector

  vcres@vcRefAnnoOn                  = True
  vcres@vcRefAnnoSide                = "Top"
  vcres@vcRefAnnoString2On           = False
  vcres@vcRefAnnoPerimOn             = True
  vcres@vcRefAnnoOrthogonalPosF      = -1.409
  vcres@vcRefAnnoParallelPosF        = 0.600
  vcres@vcRefMagnitudeF              = 10 
  vcres@vcRefAnnoString1             = "Vento: 10 m s~S~-1~N~"
  vcres@vcRefAnnoBackgroundColor     = "White"
  vcres@vcRefLengthF                 = 0.03             ; reference vector length

; 4.4.4. Create vector

  vcres@vcVectorDrawOrder            = "PostDraw"
  vector_w                          = gsn_csm_vector(wks,u,v,vcres)


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
  overlay(map,contour_psl)
  overlay(map,vector_w)

  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 
  end do
  
  end

