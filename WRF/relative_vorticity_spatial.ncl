;;; relative_vorticity_spatial.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; About          - This program is a script that will plot a series ;
;                  of variables in order to make a map.             ;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 04 Jul 2015                                      ;
; Last modified  - 09 Nov 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin. 

  begin

; 1.3. Open file.

  dir = "/home/daniela/Documents/Dissertação/Dados/WRF/" 
  a   = addfile(dir+"wrfout_d01_2006-08-27_00:00:00","r")
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Workstation and set True for some resources.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 2.1. Workstation
  wks = gsn_open_wks("png","plt_rv") 
    gsn_define_colormap(wks,"BlueWhiteOrangeRed")
  setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 500000000
  end setvalues
; 2.2. Set some basic resources 
  
  res    = True 
  pltres = True 
  mpres  = True 
  FirstTime = True
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Set time.                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  times  = wrf_user_list_times(a) ; get times in the file 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Loop, open variables and set lat/lon.                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 4.1. Loop.

  do it = 24,29 ; TIME LOOP 
  
  print("Working on time: " + times(it) ) 
  res@TimeLabel = times(it) ; Set Valid time to use on plots 
  
; 4.2. Get the data 
   
  u     = wrf_user_getvar(a,"ua",it) 
  v     = wrf_user_getvar(a,"va",it) 
  p     = wrf_user_getvar(a,"pressure",it) 
  lat2d = wrf_user_getvar(a,"lat",it) 
  lon2d = wrf_user_getvar(a,"lon",it) 

; 4.3. Set lat & lon.     
  
  lat   = lat2d(:,0) 
  lon   = lon2d(0,:) 
  
  vort            = uv2vr_cfd(u,v,lat2d(:,0),lon2d(0,:),2)
   
  rv_plane1 = wrf_user_intrp3d(vort,p,"h",950,0.,False)

  pres = wrf_user_intrp3d(p,p,"h",950,0.,False)

  delete([/u,v,p,vort,lat2d,lon2d/])
  printMinMax(rv_plane1, True)
  
  rv_plane = rv_plane1*100000 ; normalize vorticity to 10^-5 s^-1
  delete(rv_plane1)
    wrf_smooth_2d( rv_plane, 50 )  
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
  res@mpLimitMode                        = "LatLon"
  res@mpMinLonF                          = -65.0             ; longitude oeste
  res@mpMaxLonF                          = -25.0             ; longitude leste
  res@mpMinLatF                          = -50.0             ; latitude sul
  res@mpMaxLatF                          = -15.0             ; latitude norte
  res@sfXArray                           = lon
  res@sfYArray                           = lat
  res@gsnAddCyclic                       = False
  ;res@tfDoNDCOverlay                     = True          ; Necessary for contours to be overlaid correctly on WRF projection

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
  info_string1                           = "Vorticidade Relativa (10-5 s-1)"
  tf_res                                 = res
  tf_res@cnFillOn                        = True  
  tf_res@cnLinesOn                       = False 
  tf_res@cnLevelSelectionMode            = "ManualLevels"
  tf_res@cnMaxLevelValF                  = 12.0
  tf_res@cnMinLevelValF                  = -12.0
  tf_res@cnLevelSpacingF                  = 0.5

  tf_res@lbLabelFontHeightF              = 0.014
  tf_res@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res@cnInfoLabelString              = info_string1
  tf_res@lbOrientation                   = "Horizontal"
  tf_res@lbTitleFontThicknessF           = 1
  tf_res@pmLabelBarOrthogonalPosF        = 0.009
  tf_res@pmLabelBarWidthF                = 0.5
  tf_res@pmLabelBarHeightF               = 0.059 
  contour_rv                            = gsn_csm_contour(wks,rv_plane,tf_res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Set SLP contour line Resources                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  levels                                 = ispan(950,1050,2)
  info_string                            = "Press"+atilde+"o ao n"+iacute+"vel do mar de 900 a 1100 por 4"
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
  contour_psl                            = gsn_csm_contour(wks,pres,slp_res)
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
  
  overlay(map,contour_rv)
  overlay(map,contour_psl)

  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 
  end do
  end