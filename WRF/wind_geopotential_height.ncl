;;; wind_geopotential_height.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 04 Jul 2015                                      ;
; Last modified  - 20 Apr 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin. 

  begin

  dir = "/home/daniela/Documents/Dissertação/Dados/WRF/" 
  a   = addfile(dir+"wrfout_d01_2006-08-27_00:00:00","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Read variables at first time step.                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times  = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)                ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Time loop, workstation and print working on.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times1            = wrf_user_getvar(a,"Times",-1)   ; get all times in the file
  time_3            = wrf_times_c(times1, 3)          ; yyyymmddhh

  do it             = 16,17            ;
  wks               = gsn_open_wks("png",time_3(it))
  ;gsn_define_colormap(wks,"MPL_rainbow") 

  print("Working on time: " + times(it))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  lsm  = wrf_user_getvar(a,"LANDMASK",it)  ; (1 for land, 0 for water) 
  geo = wrf_user_getvar(a,"z",it)       
  tc   = wrf_user_getvar(a,"tc",it)      
  p   = wrf_user_getvar(a,"pressure",it)


; Interpolate to pressure
  
  g_plane = wrf_user_intrp3d(geo,p,"h",500.,0,False)
  t_plane = wrf_user_intrp3d(tc,p,"h",500.,0,False)


; 5.3. Lat & Lon.

  lat = a->XLAT(0,:,:)
  lon = a->XLONG(0,:,:)

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
  ;res@tfDoNDCOverlay                     = True              ; Necessary for contours to be overlaid correctly on WRF projection
  res@mpLimitMode                        = "LatLon"
  res@mpMinLonF                          = -65.0             ; longitude oeste
  res@mpMaxLonF                          = -25.0             ; longitude leste
  res@mpMinLatF                          = -50.0             ; latitude sul
  res@mpMaxLatF                          = -15.0             ; latitude norte
  res@sfXArray                           = lon
  res@sfYArray                           = lat
  res@gsnAddCyclic                       = False

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
  mpres@mpGridAndLimbOn                  = False               ; Default is every 15 deg
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Set SST contour Resources                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tf_res                                 = res
  tf_res@cnFillOn                        = True  
  tf_res@cnLinesOn                       = False 
  tf_res@cnLevelSelectionMode            = "ExplicitLevels"
  tf_res@cnLevels                        = ispan(-40,0,1)
  tf_res@lbLabelFontHeightF              = 0.014
  tf_res@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res@lbTitleString                   = "Temperatura em 500 hPa(~S~o~N~C)" ; bar title
  tf_res@lbOrientation                   = "Horizontal"
  tf_res@lbTitleFontThicknessF           = 1
  tf_res@pmLabelBarOrthogonalPosF        = 0.009
  tf_res@pmLabelBarWidthF                = 0.5
  tf_res@pmLabelBarHeightF               = 0.059 
  contour_t                            = gsn_csm_contour(wks,t_plane,tf_res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Set SLP contour line Resources                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  levels                                 = ispan(5000,6000,40)
  info_string                            = "Altura Geopotencial em 500 hPa de 5000 a 6000 por 50"
  slp_res                                = res
  slp_res@cnLineColor                    = "NavyBlue"
  slp_res@cnLevelSelectionMode           = "ExplicitLevels"
  slp_res@cnLevels                       = levels
  slp_res@cnLineLabelBackgroundColor     = -1    ; transparent
  slp_res@cnLineThicknessF               = 2.5
  slp_res@cnHighLabelsOn                 = True
  slp_res@cnLowLabelsOn                  = True
  slp_res@cnHighLabelBackgroundColor     = -1
  slp_res@cnLowLabelBackgroundColor      = -1
  slp_res@cnInfoLabelString              = info_string
  slp_res@cnInfoLabelOrthogonalPosF      = 0.127
  slp_res@cnInfoLabelParallelPosF        = 0.79
  slp_res@cnInfoLabelFontColor           = "Black"
  slp_res@cnInfoLabelPerimOn             = False   
  slp_res@cnHighLowLabelOverlapMode      = "OmitOverVPAndHL"
  contour_g                            = gsn_csm_contour(wks,g_plane,slp_res)

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

  overlay(map,contour_t) 
  overlay(map,contour_g)

  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 
  end do
  end