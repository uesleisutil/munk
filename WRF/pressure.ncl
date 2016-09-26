;;; pressure.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; About          - This program is a script that will plot a series ;
;                  of variables in order to make a map.             ;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 29 Jul 2015                                      ;
; Last modified  - 04 Nov 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.


  load "/home/uesleisutil/NCL/loads.ncl"

; 1.2. Begin. 

  begin

  a   = addfile("/home/uesleisutil/Documentos/Dissertação/Dados/wrf.nc","r")

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

  do it             = 3,4            ;
  wks               = gsn_open_wks("png",time_3(it))
  ;gsn_define_colormap(wks,"MPL_rainbow") 

  print("Working on time: " + times(it))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  slp             = wrf_user_getvar(a,"slp",it)       
 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Set level, convert unit and chance metadata.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
  res@gsnCenterString                    = " "
  res@gsnCenterStringOrthogonalPosF      = 0.01
  ;res@gsnAddCyclic                       = True
  res@tfDoNDCOverlay                     = False          ; Necessary for contours to be overlaid correctly on WRF projection
  res@tiXAxisString                      = " "
  res@tiYAxisString                      = " "
  res@tiMainString                       = times(it)

; 5.1. Set map resources.

  mpres                                  = True
  mpres                                  = res
  mpres@mpDataSetName                    = "Earth..4"          ; This new database contains
  mpres@mpDataBaseVersion                = "MediumRes"         ; Medium resolution database
  mpres@mpOutlineOn                      = True                ; Turn on map outlines
  mpres@mpDataBaseVersion                = "MediumRes"
  mpres@mpOutlineSpecifiers              = (/"Brazil:states"/)  
  mpres@mpGridAndLimbOn                  = True               ; Default is every 15 deg
  mpres@mpGridLatSpacingF                = 5
  mpres@mpGridLonSpacingF                = 5 
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
  mpres@mpMinLonF                        = -65.0             ; longitude oeste
  mpres@mpMaxLonF                        = -25.0             ; longitude leste
  mpres@mpMinLatF                        = -50.0             ; latitude sul
  mpres@mpMaxLatF                        = -15.0             ; latitude norte
  mpres@tmXBTickSpacingF                 = 2
  mpres@tmXBLabelFontHeightF             = 0.009
  mpres@tmYLTickSpacingF                 = 2
  mpres@mpGridLatSpacingF                = 2
  mpres@mpGridLonSpacingF                = 2

;Plotting options for SLP                     
; 5.1.4. Geopotential Height contour resources.
  hgt_res                                = res
  hgt_res@cnLineColor                    = "Blue"
  hgt_res@cnLevelSelectionMode           = "ExplicitLevels"
  hgt_res@cnLevels                       = ispan(950,1100,1)
  ;hgt_res@cnLineLabelBackgroundColor     = -1                  ; transparent
  hgt_res@cnLineThicknessF               = 2.5
  hgt_res@cnHighLabelsOn                 = False
  hgt_res@cnLowLabelsOn                  = False
  hgt_res@cnHighLabelBackgroundColor     = -1
  hgt_res@cnLowLabelBackgroundColor      = -1
  hgt_res@cnInfoLabelString              = " "
  hgt_res@cnInfoLabelOrthogonalPosF      = 0.237
  hgt_res@cnInfoLabelParallelPosF        = 0.79
  hgt_res@cnInfoLabelFontColor           = "Black"
  hgt_res@cnInfoLabelPerimOn             = False   
  hgt_res@cnHighLowLabelOverlapMode      = "OmitOverVPAndHL"

  contour_slp                            = gsn_csm_contour(wks,slp,hgt_res)
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

  overlay(map,contour_slp) 

  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 
  end do
  end