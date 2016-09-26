;;; wind_meridional.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 28 Jun 2015                                      ;
; Last modified  - 28 Jun 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, begin and open file                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts

  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin. 

  begin

; 1.3. Open file.

  dir = "/home/daniela/Documents/Dissertação/Dados/WRF/" 
  a   = addfile(dir+"wrfout_d01_2006-08-27_00:00:00","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. File format, name and plot color                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
  print("Working on: File format, name and plot color.")
  type = "png"
  wks = gsn_open_wks(type,"MeridionalWRF_5")
  gsn_define_colormap(wks,"BlWhRe")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Set basic resources                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
  print("Set basic resources.")
  res           = True
  res@MainTitle = "Metgrid CFSR"
  res@vpWidthF  = 0.9                       ; overwrite basic plot size
  res@vpHeightF = 1.0

  pltres        = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. File time e dims                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
  print("File time e dims.")
  FirstTime = True
  times     = wrf_user_getvar(a,"times",-1) ; get times in the file
  ntimes    = dimsizes(times)               ; number of times in the file

  mdims     = getfilevardimsizes(a,"P")     ; get some dimension sizes for the file
  nd        = dimsizes(mdims)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Loop start & set variables                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
  do it = 28,ntimes-1                     ; TIME LOOP

  print("Working on time: " + times(it))
  res@TimeLabel = times(it)              ; Set Valid time to use on plots

  th = wrf_user_getvar(a,"va",it)        ; Zonal Wind
  z  = wrf_user_getvar(a, "z",it)        ; grid point height
  p  = wrf_user_getvar(a, "pressure",it) ; grid point height


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Create cross-section                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
  print("Create cross-section.")
  opts  = True                      ; specifying start and end points
  plane = new(4,float)
  plane = (/   142,449, 411,411 /)   ; start x;y & end x;y point  

  th_plane = wrf_user_intrp3d(th,p,"v",plane,90.,opts)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Create Labels                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Create Labels.")
    if ( FirstTime ) then
    zmax = 100.     ;  Place top at model top or close to zmax
    zz = wrf_user_intrp3d(p,p,"v",plane,90.,opts)
    z_ind = ind(.not.ismissing(zz(:,0)))
    zmin = zz(z_ind(0),0)
    delete(z_ind)
    nice_levs = floor((zmin-zmax)/50)*50
    zmax = zmin - nice_levs
    dims = dimsizes(zz)
    zmax_pos = dims(0)-1
      do imax = 1,dims(0)-1
        if ( .not.ismissing(zz(imax,0)) .and. zz(imax,0) .ge. zmax ) then
        zmax_pos = imax
        end if
      end do
    zspan = zmax_pos
    zmax = zz(zmax_pos,0)
    nz = floattoint((zmin-zmax)/50+1)
    FirstTime = False
    end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Set resources                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7.1. Options for XY Plots;
    
  print("Set resources.")
  opts_xy                             = res
  opts_xy@tiYAxisString               = "Press"+atilde+"o(hPa)"
  opts_xy@AspectRatio                 = 0.75
  opts_xy@cnMissingValPerimOn         = True
  opts_xy@cnMissingValFillColor       = 0
  opts_xy@cnMissingValFillPattern     = 1
  opts_xy@tmYLMode                    = "Explicit"
  opts_xy@tmYLValues                  = fspan(0,zspan,nz)                    ; Create tick marks
  opts_xy@tmYLLabels                  = sprintf("%.0f",fspan(zmin,zmax,nz))  ; Create labels
  opts_xy@tiXAxisFontHeightF          = 0.040
  opts_xy@tiYAxisFontHeightF          = 0.020
  opts_xy@tmXBMajorLengthF            = 0.02
  opts_xy@tmYLMajorLengthF            = 0.02
  opts_xy@tmYLLabelFontHeightF        = 0.0109
  opts_xy@trXReverse                  = True                                 ; Reverse X Axis

;7.2. Plotting options for Temperature.

  print("Plotting options for Temperature.")  
  opts_th                              = True
  ;opts_th@cnInfoLabelOrthogonalPosF    = 0.15       ; move label down out of 1st plt
  opts_th@cnLevelSelectionMode         = "ManualLevels"                       ; manual contour levels
  opts_th@cnLineColor                  = "Black"
  opts_th@cnLevelSpacingF              = 5.0                                  ; contour interval
  opts_th@cnMinLevelValF               = -60.                                 ; min level
  opts_th@cnMaxLevelValF               =  60.                                 ; max level
  opts_th@cnLineLabelsOn               = True                                 ; turn on line labels
  opts_th@cnFillOn                     = True                                 ; turn on color fill
  opts_th@FieldTitle                   = "Vento Zonal"                        ; overwrite Field Title
  opts_th@gsnContourZeroLineThicknessF = 2.                                   ; doubles thickness of zero contour
  opts_th@gsnContourNegLineDashPattern = 1                                    ; sets negative contours to dash pattern 1
  opts_th@trXReverse                   = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Set contour, plot & end                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 8.1. Get the contour info for the zonal wind;
    
  print("Get the contour info for the zonal wind.")
  contour_th = wrf_contour(a,wks,th_plane(0:zmax_pos,:),opts_xy)
  contour_th2 = wrf_contour(a,wks,th_plane(0:zmax_pos,:),opts_th)

; 8.2. Make plots.        
    
  print("Make plots.")
  plot = wrf_overlays(a,wks,(/contour_th,contour_th2/),pltres)

; 8.3. Delete options and fields, so we don't have carry over.

  delete(opts_th)
  delete(th_plane)

end do

end