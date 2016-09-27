;;; cfsr_latentevento.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 29 Jul 2015                                      ;
; Last modified  - 09 Nov 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; CDO Guide:
; i.   cdo cat cfsr* cfsr_6h.nc
; ii.  cdo ydaymean cfsr_6h.nc cfsr_daily.nc
; iii. cdo selmon,11 cfsr_daily cfsr_nov.nc
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

    load "/home/uesleisutil/NCL/loads.ncl"

; 1.2. Begin. 

  begin

  a = addfile("/home/uesleisutil/Documentos/Artigo_monografia/Dados/cfsr_nov.nc","r")
  b = addfile("/home/uesleisutil/Documentos/Artigo_monografia/Dados/cfsr_nov2008.nc","r")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set time and workspace and open variables                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  time     = a->time
  times    = cd_calendar(time, -3) ; YYYYMMDDHH
  times    = times-1
  ntimes   = dimsizes(times) 
  
  do it = 0,ntimes-1
  wks               = gsn_open_wks("png",times(it))
  gsn_define_colormap(wks,"cmp_b2r") 

  sst_mean1 = a->TMP_L1(it,:,:)
  sst_20081 = b->TMP_L1(it,:,:)
  lsm       = b->LAND_L1(it,:,:)
  lon2d     = a->lon
  lat2d     = a->lat
  mask(sst2,lsm.ge.1,False)

  sst_mean = mask(sst_mean1,lsm.ge.1,False)
  sst_2008 = mask(sst_20081,lsm.ge.1,False)
  sst_anom = sst_mean - sst_2008
  

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
  res@tiMainString                       = times(it)
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
  mpres@tmXBLabelFontHeightF             = 0.012         ; change maj lat tm spacing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Set SSTA contour Resources                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tf_res3                                = res
  tf_res3@cnFillOn                       = True  
  tf_res3@cnLinesOn                      = False 
  tf_res3@cnLevelSelectionMode           = "ManualLevels"
  tf_res3@cnLevelSpacingF                = 0.05
  tf_res3@cnMinLevelValF                 = -2
  tf_res3@cnMaxLevelValF                 = 02
  tf_res3@lbLabelFontHeightF             = 0.014
  tf_res3@lbTitleFontHeightF             = .015            ; make title smaller
  tf_res3@lbTitleString                  = "Anomalia da Temperatura da Superf"+iacute+"cie do Mar(~S~o~N~C)" ; bar titl
  tf_res3@lbOrientation                  = "Horizontal"
  tf_res3@lbTitleFontThicknessF          = 1
  tf_res3@lbLabelConstantSpacingF        = 1
  tf_res3@pmLabelBarOrthogonalPosF       = 0.109
  tf_res3@pmLabelBarWidthF               = 0.5
  tf_res3@pmLabelBarHeightF              = 0.059 
 ;tf_res@cnFillPalette                   = "MPL_jet"
  contour_sst                             = gsn_csm_contour(wks,sst_anom,tf_res3)

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
 
  end do
  end