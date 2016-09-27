;;; cfsr_climatologia.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 26 Jul 2016                                      ;
; Last modified  - 26 Jul 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

  load "/home/uesleisutil/NCL/loads.ncl"

; 1.2. Begin. 

  begin

  a   = addfile("/home/uesleisutil/Documentos/Artigo_monografia/Dados/cfsr_climato.nc","r")
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set things.                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 2.1. Set time.
  time         = a->time
  times        = cd_calendar(time, -3) ; YYYYMMDDHH
  times        = times-1
  ntimes       = dimsizes(times) 

; 2.1. Get variable.
  temp1        = a->TMP_L1_Avg
  temp2         = temp1-273.15
  copy_VarCoords(temp1, temp2)

  lsm          = a->LAND_L1_Avg
  temp         = mask(temp2,lsm.ge.1,False)

  lon2d        = a->lon
  lat2d        = a->lat
; Calculate climatology

  clim        = clmMonTLL(temp)

; Do the seasonal means.

  djf          = ((clim(11,:,:) + clim(00,:,:) + clim(01,:,:))/3)
  mam          = ((clim(02,:,:) + clim(03,:,:) + clim(04,:,:))/3)
  jja          = ((clim(05,:,:) + clim(06,:,:) + clim(07,:,:))/3)
  son          = ((clim(08,:,:) + clim(09,:,:) + clim(10,:,:))/3)
  
  estacao      = son

; Set workstation.

  wks          = gsn_open_wks("png","estacao")
  gsn_define_colormap(wks,"MPL_jet")   
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
  res@tiMainString                       = times
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
  tf_res@cnLevelSpacingF                 = 0.3
  tf_res@cnMinLevelValF                  = 13
  tf_res@cnMaxLevelValF                  = 27
  tf_res@lbLabelFontHeightF              = 0.014
  tf_res@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res@lbTitleString                   = "Temperatura da Superf"+iacute+"cie do Mar (~S~o~N~C)" ; bar title
  tf_res@lbOrientation                   = "Horizontal"
  tf_res@lbTitleFontThicknessF           = 1
  tf_res@lbMinLabelSpacingF  = 1.7
  tf_res@pmLabelBarOrthogonalPosF        = 0.109
  tf_res@pmLabelBarParallelPosF          = 0.509
  tf_res@pmLabelBarWidthF                = 0.5
  tf_res@pmLabelBarHeightF               = 0.059 
 ;tf_res@cnFillPalette                   = "MPL_jet"
  contour_sst                             = gsn_csm_contour(wks,estacao,tf_res)

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


  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 

  end