  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin.
  
  begin

; 1.3. Open WRF output file.


  dir = "/home/daniela/Documents/Dissertação/Dados/WRF/" 
  a   = addfile(dir+"wrfout_d01_2006-08-25_00:00:00","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Read variables at first time step.                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times  = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)                ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Time loop, workstation and print working on.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times1 = wrf_user_getvar(a,"Times",-1)   ; get all times in the file
  time_3 = wrf_times_c(times1, 3)         ; yyyymmddhh

  do it  = 32,40            ; TIME LOOP
  wks    = gsn_open_wks("png",time_3(it))
  
  print("Working on time: " + times(it))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  p1  = wrf_user_getvar(a,"pressure",it)  ;pressure levels

  u1  = wrf_user_getvar(a,"ua",it) 
  u   = wrf_user_intrp3d(u1,p1,"h",500,0,False)
  delete(u1)

  v1  = wrf_user_getvar(a,"va",it) 
  v   = wrf_user_intrp3d(v1,p1,"h",500,0,False)
  delete(v1)

  t1  = wrf_user_getvar(a,"tc",it)
  t   = wrf_user_intrp3d(t1,p1,"h",500,0,False)
  delete(t1)

  z1 = wrf_user_getvar(a, "z",it)        ;geopotential heights
  z  = wrf_user_intrp3d(z1,p1,"h",500.,0,False)
  delete(z1)
  
  delete(p1)
  
; Function: adv_X =  U*(dX/dlon) + V*(dX/dlat)

  adv = advect_var(u, v, t, 1, "advection of temperature", "m-C/s", 0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Set global Resources                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  res                                    = True
  res@gsnFrame                           = False
  res@gsnDraw                            = False
  res@gsnLeftString                      = " "
  res@gsnRightString                     = " "
  res@gsnCenterString                    = times(it)
  res@gsnCenterStringOrthogonalPosF      = 0.01
  res@tfDoNDCOverlay                     = True          ; Necessary for contours to be overlaid correctly on WRF projection

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Set SST contour Resources                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tf_res                                 = res
  tf_res@cnFillOn                        = True  
  tf_res@cnLinesOn                       = False 
 ; tf_res@cnLevelSelectionMode            = "ExplicitLevels"
  ;tf_res@cnLevels                        = fspan(0,1,0.1)
 ; tf_res@cnMaxLevelValF                  = 1
 ; tf_res@cnMinLevelValF                  = 0
 ; tf_res@cnLevelSpacingF                 = 0.1
  tf_res@lbLabelFontHeightF              = 0.014
  tf_res@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res@lbTitleString                   = "Adveccao da Temperatura em 500 hPa " ; bar title
  tf_res@lbOrientation                   = "Horizontal"
  tf_res@lbTitleFontThicknessF           = 1
  tf_res@pmLabelBarOrthogonalPosF        = 0.009
  tf_res@pmLabelBarWidthF                = 0.5
  tf_res@pmLabelBarHeightF               = 0.059 
  contour_adv                            = gsn_csm_contour(wks,adv,tf_res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Set SLP contour line Resources                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  levels                               = ispan(4800,6000,70)
  info_string                          = "Altura Geopotencial em 500 hPa (mgp) de 5500 a 6000 por 50"
  z_res                                = res
  z_res@cnInfoLabelString              = info_string
  z_res@cnLineColor                    = "NavyBlue"
  z_res@cnLevelSelectionMode           = "ExplicitLevels"
  z_res@cnLevels                       = levels
  z_res@cnLineLabelBackgroundColor     = -1    ; transparent
  z_res@cnLineThicknessF               = 2.5
  z_res@cnHighLabelsOn                 = True
  z_res@cnLowLabelsOn                  = True
  z_res@cnHighLabelBackgroundColor     = -1
  z_res@cnLowLabelBackgroundColor      = -1
  z_res@cnInfoLabelOrthogonalPosF      = 0.127
  z_res@cnInfoLabelParallelPosF        = 0.79
  z_res@cnInfoLabelFontColor           = "Black"
  z_res@cnInfoLabelPerimOn             = False
  contour_z                          = gsn_csm_contour(wks,z,z_res)

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

  overlay(map,contour_adv) 
  overlay(map,contour_z)
  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)





end do 
end