;;; wind_latente_heat.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; About          - This program is a script that will plot a series ;
;                  of variables in order to make a map.             ;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 10 Nov 2015                                      ;
; Last modified  - 10 Nov 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  load "/home/uesleisutil/NCL/loads.ncl"

; 1.2. Begin. 

  begin

  a   = addfile("/home/uesleisutil/Documentos/Dissertação/Dados/wrf.nc","r")

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
 
  do it = 17,18            ; TIME LOOP

; 3.2. Open Workstation and define colormap, then print.
 
  wks   = gsn_open_wks("png",time_3(it))
 ; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed") 
  print("Working on time: " + times(it))

 setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize" : 300000000
 end setvalues

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  lat2d = wrf_user_getvar(a,"XLAT",it)   ; latitude
  lon2d = wrf_user_getvar(a,"XLONG",it)  ; longitude
  
  lsm   = wrf_user_getvar(a,"LANDMASK",it)  ; (1 for land, 0 for water) 
  
  lh    = wrf_user_getvar(a,"LH",it)    
  ;lh    = mask(lh1,lsm.ge.1,False)         
   
  uvm   = wrf_user_getvar(a,"uvmet10",it)
  u     = uvm(0,:,:)
  v     = uvm(1,:,:)

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

; 5.2. Set LH resources.

  tf_res                            = True
  tf_res@cnFillOn                   = True  
  tf_res@sfXArray                   = lon2d
  tf_res@sfYArray                   = lat2d
  tf_res@cnLinesOn                  = False 
  tf_res@cnLevelSelectionMode       = "ExplicitLevels"
  tf_res@cnLevels                   = ispan(0,550,20)
  tf_res@lbLabelFontHeightF         = 0.014
  tf_res@lbTitleFontHeightF         = .015            ; make title smaller
  tf_res@lbTitleString              = "Fluxo de Calor Latente (W m~S~-2~N~)" ; bar title
  tf_res@lbOrientation              = "Horizontal"
  tf_res@lbTitleFontThicknessF      = 1
  tf_res@pmLabelBarOrthogonalPosF   = 0.039
  tf_res@pmLabelBarWidthF           = 0.5
  tf_res@pmLabelBarHeightF          = 0.059 
  contour_lh                        = gsn_csm_contour(wks,lh,tf_res)

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

  plot = wrf_map_overlays(a,wks,(/contour_lh,vector_w/),pltres,mpres)

end do

end
