;;; pressure.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 21 Apr 2016                                      ;
; Last modified  - 21 Apr 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

  load "/home/uesleisutil/NCL/loads.ncl"

; 1.2. Begin. 

  begin

  a   = addfile("/home/uesleisutil/Documentos/Dissertação/Dados/cfsr_pressao.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set variables and do,                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 2.1. Set time.
  time         = a->time
  times        = cd_calendar(time, -3) ; YYYYMMDDHH
  times        = times-1
  ntimes       = dimsizes(times) 

; 2.3. Set start.
  do it        = 0,ntimes-1
  print("Working on time: " + times(it) )
   
; 2.5. Set variables.
   slp1         = a->PRES_L101(it,:,:)
   slp          = slp1/100  ; Pa to HPa
   copy_VarCoords(slp1, slp)
  ; wrf_smooth_2d(hgt, 20)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Set global Resources                                           ;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set map Resources I                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
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
  mpres@mpMinLonF                        = -60.0               ; longitude oeste
  mpres@mpMaxLonF                        = -25.0               ; longitude leste
  mpres@mpMinLatF                        = -60.0               ; latitude sul
  mpres@mpMaxLatF                        = -15.0               ; latitude norte
  mpres@tmXBTickSpacingF                 = 2
  mpres@tmXBLabelFontHeightF             = 0.009
  mpres@tmYLTickSpacingF                 = 2
  mpres@mpGridLatSpacingF = 2
  mpres@mpGridLonSpacingF = 2
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Set SLP Resources                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 5.1.1 Workstation option        
  wks                                    = gsn_open_wks("png",times(it))
  gsn_define_colormap(wks,"cmp_b2r")                      ; Colorbar
     
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
; 6. Set map Resources II                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mpres@gsnFrame                         = False
  mpres@gsnDraw                          = False
  mpres                                  = wrf_map_resources(a,mpres)
  map                                    = gsn_csm_map(wks,mpres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Overlay plots on map and draw                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  overlay(map,contour_slp) 

  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
  
  end do

  end