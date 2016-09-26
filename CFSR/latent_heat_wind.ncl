;;; latent_heat_wind.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

  f   = addfile("/home/daniela/Documents/Dissertação/Dados/cfsr_latentevento.nc","r")
  f   = addfile("/home/daniela/Documents/Dissertação/Dados/cfsr_latentevento.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Time loop, workstation and print working on.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it             = 0,52            ; TIME LOOP
  
  wks               = gsn_open_wks("png","latente_"+it)
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed") 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
  lsm   = f->LAND_L1(it,:,:)
  u     = f->U_GRD_L100(it,9,:,:)
  v     = f->V_GRD_L100(it,9,:,:)
  lh_1  = f->LHTFL_L1(it,:,:)
  lh    = mask(lh_1,lsm.ge.1,False)

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
  ;res@tfDoNDCOverlay                     = True          ; Necessary for contours to be overlaid correctly on WRF projection

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Set map Resources I                                            ;
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
  mpres@mpMinLonF                        = -65.0          ; longitude oeste
  mpres@mpMaxLonF                        = -25.0          ; longitude leste
  mpres@mpMinLatF                        = -50.0          ; latitude sul
  mpres@mpMaxLatF                        = -15.0          ; latitude norte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Set LH contour Resources                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tf_res                                 = res
  tf_res@cnFillOn                        = True  
  tf_res@cnLinesOn                       = False 
  tf_res@cnLevelSelectionMode            = "ExplicitLevels"
  tf_res@cnLevels                        = ispan(0,600,20)
  tf_res@lbLabelFontHeightF              = 0.014
  tf_res@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res@lbTitleString                   = "Fluxo de Calor Latente (W m~S~-2~N~)" ; bar title
  tf_res@lbOrientation                   = "Horizontal"
  tf_res@lbTitleFontThicknessF           = 1
  tf_res@pmLabelBarOrthogonalPosF        = 0.109
  tf_res@pmLabelBarWidthF                = 0.5
  tf_res@pmLabelBarHeightF               = 0.059 
  tf_res@FieldTitle                      = " "           ; overwrite Field Title
 ;tf_res@cnFillPalette                   = "MPL_jet"
  contour_lh                             = gsn_csm_contour(wks,lh,tf_res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Set Wind contour line Resources                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 8.1. Vector resources.

; 8.1.1. Vector Global resources

  vcres                              = res         
  vcres@vcGlyphStyle                 = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF               = 0.030            ; thin out vectors
  vcres@vcLineArrowThicknessF        = 4
  ;vcres@vcMinFracLengthF            = 1                 ; "Broken vector"

; 8.1.2. If Coloured Vectors 

  vcres@gsnFrame                     = False
  vcres@gsnDraw                      = False
  vcres@vcMonoLineArrowColor         = True
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

; 8.1.3. If Reference Vector

  vcres@vcRefAnnoOn                  = False
  vcres@vcRefAnnoSide                = "Top"
  vcres@vcRefAnnoString2On           = False
  vcres@vcRefAnnoPerimOn             = True
  vcres@vcRefAnnoOrthogonalPosF      = -1.309
  vcres@vcRefAnnoParallelPosF        = 0.600
  vcres@vcRefMagnitudeF              = 10 
  vcres@vcRefAnnoString1             = "Vento: 10 m s~S~-1~N~"
  vcres@vcRefAnnoBackgroundColor     = "White"
  vcres@vcRefLengthF                 = 0.03             ; reference vector length

; 8.1.4. Create vector

  vcres@vcVectorDrawOrder            = "PostDraw"
  vector_w                          = gsn_csm_vector(wks,u,v,vcres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Set map Resources II                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mpres@gsnFrame                         = False
  mpres@gsnDraw                          = False
  mpres                                  = wrf_map_resources(f,mpres)
  map                                    = gsn_csm_map(wks,mpres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 10. Overlay plots on map and draw                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  overlay(map,contour_lh) 
  overlay(map,vector_w)
 
  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 
  end do
  end