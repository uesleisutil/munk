;;; cross_section_relative_vorticity.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; About          - This program is a script that will plot a series ;
;                  of variables in order to make a cross section.   ;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 19 Nov 2015                                      ;
; Last modified  - 19 Nov 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin. 

  begin

; 1.3. Open file.

  dir = "/home/daniela/Documents/Dissertação/Dados/WRF/" 
  a   = addfile(dir+"wrfout_d01_2006-08-27_00:00:00","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2.  Set resources.                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  res    = True  
  pltres = True 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3.  Time options.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime    = True 
  FirstTimeMap = True 
  times        = wrf_user_list_times(a) ; get times in the file 
  ntimes       = dimsizes(times) ; number of times in the file 
  
  times1       = wrf_user_getvar(a,"Times",-1)   ; get all times in the file
  time_3       = wrf_times_c(times1, 3)          ; yyyymmddhh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4.  Do, open file variables.                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
; 4.1. Do.
  
  do it = 28,29
  
  print("Working on time: " + times(it)) 

; 4.2. WKS info.

  wks = gsn_open_wks("png",time_3(it))

; 4.3. Open variables.

  mdims = getfilevardimsizes(a,"P") ; get some dimension sizes for the file 
  nd    = dimsizes(mdims) 
   
  lat2d = wrf_user_getvar(a, "lat",it) 
  lon2d = wrf_user_getvar(a, "lon",it)
  lat   = lat2d(:,0) 
  lon   = lon2d(0,:) 


  z     = wrf_user_getvar(a, "z",it) ; grid point height 
  u     = wrf_user_getvar(a,"ua",it) ; 3D componente U en mass points    
  v     = wrf_user_getvar(a,"va",it) ; 3D componente V en mass points 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4.  Regrid data and calculate RV                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 4.1. Regrid.

  u_grid = rcm2rgrid(lat2d,lon2d,u,lat,lon,1)
  v_grid = rcm2rgrid(lat2d,lon2d,v,lat,lon,1) 

; 4.2. Calculate RV.

  rv           = uv2vr_cfd(u_grid,v_grid,lat,lon,3) 
 ;rv           = uv2vrF_Wrap(u,v) 
  rv@long_name = "relative vorticity" 
  rv@units     = "1/s" 
  rv!0         = "time" 
  rv!1         = "lat" 
  rv!2         = "lon" 
  rv@lat       = lat 
  rv@lon       = lon 
  ;copy_VarCoords(u,rv) 
  printVarSummary(rv) 
  rv_grid1      = rgrid2rcm (lat, lon, rv, lat2d, lon2d, 0) 
  rv_grid = rv_grid1*10^5 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5.  Create height info                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  if ( FirstTime ) then ; get height info for labels 
    zmin = 0. 
    zmax = 3. ; First 3km 
    nz = floattoint(zmax + 1) 
  end if 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5.  Set lat and lon.                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 5.1. Chosse lat e lon.

  lat = (/ -37.0, -37.0 /) 
  lon = (/ -60, -30 /) 

  nm      = getind_latlon2d (xlat,xlon, lat, lon) ; return 2d subscripts 
  angle   = 0 
  plane   = new(4,float) 
  plane   = (/ nm(0,1), nm(0,0), nm(1,1), nm(1,0) /) ; approx. start x;y and end x;y point 
  opts    = True 
  X_plane = wrf_user_intrp2d(xlon,plane,angle,opts) 
  X_desc  = "Longitude" 
  
; 5.2.  Find the index where 3km is - only need to do this once 
    
  if ( FirstTime ) then 
    zz = wrf_user_intrp3d(z,z,"v",plane,angle,opts) 
    b = ind(zz(:,0) .gt. zmax*1000. ) 
    zmax_pos = b(0) - 1 
      if ( abs(zz(zmax_pos,0)-zmax*1000.) .lt. abs(zz(zmax_pos+1,0)-zmax*1000.) ) then 
        zspan = b(0) - 1 
      else 
        zspan = b(0) 
      end if 
  delete(zz) 
  delete(b) 
    FirstTime = False 
  end if 
 
; 5.3. Set X-axis lables 

  dimsX = dimsizes(X_plane) 
  xmin  = X_plane(0) 
  xmax  = X_plane(dimsX(0)-1) 
  xspan = dimsX(0)-1 
  nx    = floattoint( (xmax-xmin)/2 + 1) 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6.  Set resources and planes.                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 6.1. Options for XY Plots 
  
  opts_xy                           = res 
  opts_xy@tiXAxisString             = X_desc 
  opts_xy@tiYAxisString             = "Altura (km)" 
  opts_xy@cnMissingValPerimOn       = True 
  opts_xy@cnMissingValFillColor     = 0 
  opts_xy@cnMissingValFillPattern   = 11 
  opts_xy@tmXTOn                    = False 
  opts_xy@tmYROn                    = False 
  opts_xy@tmXBMode                  = "Explicit" 
  opts_xy@tmXBValues                = fspan(0,xspan,nx) ; Create tick marks 
  opts_xy@tmXBLabels                = sprintf("%.1f",fspan(xmin,xmax,nx)) ; Create labels 
  opts_xy@tmXBLabelFontHeightF      = 0.015 
  opts_xy@tmYLMode                  = "Explicit" 
  opts_xy@tmYLValues                = fspan(0,zspan,nz) ; Create tick marks 
  opts_xy@tmYLLabels                = sprintf("%.1f",fspan(zmin,zmax,nz)) ; Create labels 
  opts_xy@tiXAxisFontHeightF        = 0.020 
  opts_xy@tiYAxisFontHeightF        = 0.020 
  opts_xy@tmXBMajorLengthF          = 0.02 
  opts_xy@tmYLMajorLengthF          = 0.02 
  opts_xy@tmYLLabelFontHeightF      = 0.015 
  opts_xy@vcMapDirection            = False

; 6.2. Do the planes.

  tc_plane = wrf_user_intrp3d(rv_grid,z,"v",plane,angle,opts_xy) 
  u_plane  = wrf_user_intrp3d(u,z,"v",plane,0,opts_xy) 
  v_plane  = wrf_user_intrp3d(v,z,"v",plane,0,opts_xy) 


; 6.3. Plotting options for RH
  opts_rh                           = opts_xy
  opts_rh@cnInfoLabelOrthogonalPosF = 0.00
  opts_rh@ContourParameters         = (/ 10., 100., 10. /)

; 6.4. Plotting options for Wind Vectors 
  opts_wv                           = opts_xy 
  opts_wv@FieldTitle                = "Wind" ; overwrite Field Title 
  opts_wv@NumVectors                = 50 ; density of wind barbs 
  opts_wv@vcGlyphStyle              = "CurlyVector" 
  vector                            = wrf_vector(a,wks,u_plane(0:zmax_pos,:),v_plane(0:zmax_pos,:),opts_wv) 
  delete(opts_wv) 

; 6.5 Plotting options for Temperature 
  opts_tc                           = opts_xy 
  opts_tc@ContourParameters         = (/ 0., 30., 2. /) 
  opts_tc@pmLabelBarOrthogonalPosF  = -0.1 
  opts_tc@cnFillOn                  = True 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Create contour.                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  contour_tc = wrf_contour(a,wks,tc_plane(0:zmax_pos,:),opts_tc) 
  contour_rh = wrf_contour(a,wks,rh_plane(0:zmax_pos,:),opts_rh)
       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Create plots.                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 8.1. Create plots. 

  if (FirstTimeMap) then 
    lat_plane              = wrf_user_intrp2d(xlat,plane,angle,opts) 
    lon_plane              = wrf_user_intrp2d(xlon,plane,angle,opts) 
    mpres                  = True 
    pltres                 = True 
    pltres@FramePlot       = False 
    optsM                  = res 
    optsM@NoHeaderFooter   = True 
    optsM@cnFillOn         = True 
    optsM@lbTitleOn        = False 
    contour                = wrf_contour(a,wks,ter,optsM) 
    plot                   = wrf_map_overlays(a,wks,(/contour/),pltres,mpres) 
    lnres                  = True 
    lnres@gsLineThicknessF = 3.0 
    lnres@gsLineColor      = "Red" 
      
      do ii = 0,dimsX(0)-2 
        gsn_polyline(wks,plot,(/lon_plane(ii),lon_plane(ii+1)/),(/lat_plane(ii),lat_plane(ii+1)/),lnres) 
        end do 
    frame(wks) 
    delete(lon_plane) 
    delete(lat_plane) 
    pltres@FramePlot = True 
   
  end if 
       
    plot = wrf_overlays(a,wks,(/contour_tc,vector/),pltres) ; plot x-section 
  
; 8.2. Delete options and fields, so we don't have carry over 
  
  delete(opts_xy) 
  delete(opts_tc) 
  delete(tc_plane) 
  delete(X_plane) 
 
  end do  
end 