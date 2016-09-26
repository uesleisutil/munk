;;; wind_potential_temp.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 10 Jul 2015                                      ;
; Last modified  - 05 Jan 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin. 

  begin

; 1.3. Directory.

  dir = "/home/daniela/Documents/Dissertação/Dados/WRF/" 
  a   = addfile(dir+"wrfout_d01_2006-08-27_00:00:00","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Read variables at first time step.                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times  = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)                ; number of times in the file
  times1 = wrf_user_getvar(a,"Times",-1)   ; get all times in the file
  time_3 = wrf_times_c(times1, 3)         ; yyyymmddhh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Time loop, workstation and print working on.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 3.1. Do.
 
  do it             = 28,29            ; TIME LOOP

; 3.2. Open Workstation and define colormap, then print.
 
  wks               = gsn_open_wks("png",time_3(it))
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed") 
  print("Working on time: " + times(it))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  lat2d = wrf_user_getvar(a,"XLAT",it)   ; latitude
  lon2d = wrf_user_getvar(a,"XLONG",it)  ; longitude
  p     = wrf_user_getvar(a,"pressure",it)
  lsm   = wrf_user_getvar(a,"LANDMASK",it)  ; (1 for land, 0 for water) 
  
  th1   = wrf_user_getvar(a,"theta",it)   
  th2   = th1-273.15
  copy_VarCoords(th1, th2)
  th    = wrf_user_intrp3d(th2,p,"h",925.,0,False)
  ;th   = mask(th3,lsm.ge.1,False)         
  
  u1    = wrf_user_getvar(a,"ua",it) 
  u     = wrf_user_intrp3d(u1,p,"h",925.,0,False)
  v1    = wrf_user_getvar(a,"va",it)     
  v     = wrf_user_intrp3d(v1,p,"h",925.,0,False)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Set Resources                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 5.1. Set map resources.

  mpres                             = True
  mpres@mpDataSetName               = "Earth..4"     ; This new database contains
  mpres@mpDataBaseVersion           = "MediumRes"    ; Medium resolution database
  mpres@mpOutlineOn                 = True           ; Turn on map outlines
  mpres@mpDataBaseVersion           = "MediumRes"
  mpres@mpOutlineSpecifiers         = (/"Brazil:states"/)  
  mpres@mpGridAndLimbOn             = False          ; Default is every 15 deg
  mpres@mpProvincialLineColor       = "black"        ; States line color line
  mpres@mpGeophysicalLineColor      = "black"        ; Contour map color line
  mpres@mpNationalLineColor         = "black"        ; Continent  olor line
  mpres@pmLegendOrthogonalPosF      = -0.99          ; Wind legend localization
  mpres@pmLegendParallelPosF        = 1.0            ; Wind legend localization
  mpres@mpProvincialLineThicknessF  = 3              ; State line thickness  
  mpres@mpNationalLineThicknessF    = 3              ; Continent line thickness
  mpres@mpGeophysicalLineThicknessF = 3.0
  mpres@mpPerimOn                   = True
  mpres@mpPerimLineThicknessF       = 3.0

  mpres@mpLeftCornerLatF            = -50.
  mpres@mpRightCornerLatF           = -15.
  mpres@mpLeftCornerLonF            = -65.
  mpres@mpRightCornerLonF           = -25.

; 5.2. Set TP resources.

  tf_res                            = True
  tf_res@cnFillOn                   = True 
  tf_res@cnFillMode                 = "RasterFill" 
  tf_res@sfXArray                   = lon2d
  tf_res@sfYArray                   = lat2d
  tf_res@cnLinesOn                  = False 

  tf_res@cnLevelSelectionMode       = "ExplicitLevels"
  tf_res@cnLevels                   = ispan(0,30,1)
  tf_res@lbLabelFontHeightF         = 0.014
  tf_res@lbTitleFontHeightF         = .015            ; make title smaller
  tf_res@lbTitleString              = "Temperatura Potencial (~S~o~N~C) em 925 hPa" ; bar title
  tf_res@lbOrientation              = "Horizontal"
  tf_res@lbTitleFontThicknessF      = 1
  tf_res@pmLabelBarOrthogonalPosF   = 0.039
  tf_res@pmLabelBarWidthF           = 0.5
  tf_res@pmLabelBarHeightF          = 0.059 
  contour_th                        = gsn_csm_contour(wks,th,tf_res)

; 5.3. Set Wind Resources.
  
  vcres                             = True
  vcres@vcGlyphStyle                = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF              = 0.030            ; thin out vectors
  vcres@vcLineArrowThicknessF       = 4
  vcres@vcRefAnnoOn                 = True
  vcres@vcRefAnnoSide               = "Top"
  vcres@vcRefAnnoString2On          = False
  vcres@vcRefAnnoPerimOn            = True
  vcres@vcRefAnnoOrthogonalPosF     = -1.509
  vcres@vcRefAnnoParallelPosF       = 0.600
  vcres@vcRefMagnitudeF             = 10 
  vcres@vcRefAnnoString1            = "Vento: 10 m s~S~-1~N~"
  vcres@vcRefAnnoBackgroundColor    = "White"
  vcres@vcRefLengthF                = 0.03             ; reference vector length
  vcres@vfXArray                    = lon2d
  vcres@vfYArray                    = lat2d
  vector_w                          = wrf_vector(a, wks, u, v, vcres)


; 5.3. Set plot Resources.
  
  pltres                            = True
  pltres@LatLonOverlay              = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Plot                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  plot = wrf_map_overlays(a,wks,(/contour_th,vector_w/),pltres,mpres)

end do

end
