 ;*******************************************************************;
;* Script    - OverlayDef.ncl                                      *;
;*                                                                 *;
;* Author    - Ueslei Adriano Sutil                                *;
;*                                                                 *;
;* Created   - 29 jul 2015                                         *;
;* Update    - 29 jun 2015                                         *;
;*                                                                 *;
;* About     - This program is a script that will plot a series of *;
;*             variables in order to make a map.                   *;
;* Input     - Metgrid, WRF, COAWST                                *;
;* Variables - Latent Heat and Wind                                *;
;*                                                                 *;
;*******************************************************************;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

     load "/home/ueslei/Documentos/NCL/scripts/loads.ncl"

begin
   
     dir = "/home/ueslei/Documentos/Dissertação/Dados/COAWST/"
     a = addfile(dir+"wrfout_d01_2006-08-27_00:00:00","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Read variables at first time step.                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times  = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)                ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Time loop, workstation and print working on.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times1         = wrf_user_getvar(a,"Times",-1)   ; get all times in the file
  time_3         = wrf_times_c(times1, 3)         ; yyyymmddhh

  do it          = 28,ntimes-1            ; TIME LOOP
  wks            = gsn_open_wks("png",time_3(it))
    gsn_define_colormap(wks,"gsltod")
  print("Working on time: " + times(it))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 4.1. Land-Sea Mask.

  lsm           = wrf_user_getvar(a,"LANDMASK",it)  ; (1 for land, 0 for water) 

; 4.2. OLR

  olr            = wrf_user_getvar(a,"OLR",it)       

    
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
  tf_res@cnLevelSelectionMode            = "ExplicitLevels"
  tf_res@cnLevels                        = ispan(100,340,20)
  tf_res@lbLabelFontHeightF              = 0.014
  tf_res@lbTitleFontHeightF              = .015            ; make title smaller
  tf_res@lbTitleString                   = "Outgoing Longwave Radiation (W m~S~-2~N~)" ; bar title
  tf_res@lbOrientation                   = "Horizontal"
  tf_res@lbTitleFontThicknessF           = 1
  tf_res@pmLabelBarOrthogonalPosF        = 0.109
  tf_res@pmLabelBarWidthF                = 0.5
  tf_res@pmLabelBarHeightF               = 0.059 
  contour_olr                            = gsn_csm_contour(wks,olr,tf_res)

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

  overlay(map,contour_olr)


  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
 
  end do
  end