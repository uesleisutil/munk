  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin. 

  begin

; 1.3. Open file.

  dir = "/home/daniela/Documents/Dissertação/Dados/WRF/" 
  a   = addfile(dir+"wrfout_d01_2006-08-27_00:00:00","r")




; We generate plots, but what kind do we prefer?
; type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  type = "png"
  wks = gsn_open_wks(type,"cross_section")
  gsn_define_colormap(wks,"BlueWhiteOrangeRed")

  wks2  = gsn_open_wks(type,"plan_map")

; Set some basic resources
  res = True
  res@Footer = False
  
  pltres = True

; Set the path the cross section will take
  lat_start = -36.00
  lon_start = -60.00
  lat_end   = -36.00
  lon_end   = -30.00

; Limited vertical extent? (True or False)
LimitedExtent   = True
z_top       = 11.   ; top in km (ignored if above is False)

; What type of reference plan view (vort or ter)
planview    = "ter"

if ( planview.eq."ter") then
    gsn_define_colormap(wks2,"MPL_Blues")
else if ( planview.eq."vort") then
    gsn_define_colormap(wks2,"BlueWhiteOrangeRed")
else
    print("INVALID PLANVIEW TYPE!!!")
end if
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times  = wrf_user_getvar(a,"times",-1)    ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
  FirstTime = True

  mdims = getfilevardimsizes(a,"P") ; get some dimension sizes for the file
  nd = dimsizes(mdims)

;---------------------------------------------------------------

  FirstTimeMap = True

  do it = 28,29                  ; TIME LOOP

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)           ; Set Valid time to use on plots

    tc  = wrf_user_getvar(a,"tc",it)        ; temperature (deg C)
    rh  = wrf_user_getvar(a,"rh",it)        ; relative humidity (%)
    z   = wrf_user_getvar(a, "z",it)        ; grid point height (m)
    p   = wrf_user_getvar(a,"pressure",it)  ; full model pressure (hPa)
    u   = wrf_user_getvar(a,"ua",it)        ; x-component wind (m/s)
    v   = wrf_user_getvar(a,"va",it)        ; y-component wind (m/s)
    lat = wrf_user_getvar(a,"lat",it)       ; latitude grid
    lon = wrf_user_getvar(a,"lon",it)       ; longitude grid
    ter = wrf_user_getvar(a,"HGT",it)       ; model terrain height (m)

; Compute the relative vorticity from the u and v wind fields
vort            = uv2vr_cfd(u,v,lat(:,0),lon(0,:),2)
vort@description    = "Relative Vorticity"
vort@units      = "1/s"

    if ( FirstTime ) then               ; get height info for labels
      zmin  = 0.            ; bottom of plot

    if ( LimitedExtent ) then
        angle   = 0.
        zmax    = z_top
        nz  = floattoint(zmax + 1)
    else
        angle       = 0.
        zmax        = max(z) / 1000.
        nz      = floattoint(zmax / 2 + 1)
        FirstTime   = False
    end if
    end if

;---------------------------------------------------------------

; Plot a cross session that run from point A to point B

    ; starting point for cross-section
    llres = True
    llres@ReturnInt = False
    locij_a = wrf_user_ll_to_ij(a, lon_start, lat_start, llres)
    locij_a = locij_a - 1                                                       ; array pointers in NCL space
    locX_a = locij_a(0)
    locY_a = locij_a(1)

    ; ending point for cross-section
    locij_b = wrf_user_ll_to_ij(a, lon_end, lat_end, llres)
    locij_b = locij_b - 1                                                       ; array pointers in NCL space
    locX_b = locij_b(0)
    locY_b = locij_b(1)

        plane = new(4,float)
        plane = (/ locX_a,locX_b , locY_a,locY_b /)    ; start x;y &amp; end x;y point           
        opts = True                                        ; start and end points specified

    rh_plane   = wrf_user_intrp3d(rh,z,"v",plane,0.,opts)  ; relative humidity plane
    tc_plane   = wrf_user_intrp3d(tc,z,"v",plane,0.,opts)  ; temperature plane
    p_plane     = wrf_user_intrp3d(p,z,"v",plane,0.,opts)   ; pressure plane
    vort_plane  = wrf_user_intrp3d(vort,z,"v",plane,0.,opts)    ; relative vorticity plane
    u_plane  = wrf_user_intrp3d(u,z,"v",plane,0.,opts)    ; relative vorticity plan
    v_plane  = wrf_user_intrp3d(v,z,"v",plane,0.,opts)    ; relative vorticity plan



    vort_plane      = vort_plane * 100000.      ; normalize vorticity to 10^-5 s^-1
    vort_plane@units    = "10^5 s^-1"

        dim = dimsizes(vort_plane)                      ; Find the data span - for use in labels
        zspan = dim(0)

    if ( FirstTime ) then
        angle       = 0.
        zz      = wrf_user_intrp3d(z,z,"v",plane,angle,opts)
        b       = ind(zz(:,0).gt.zmax*1000.)
        zmax_pos    = b(0) - 1
        if ( abs(zz(zmax_pos,0)-zmax*1000.).lt.abs(zz(zmax_pos+1,0)-zmax*1000.) ) then
            zspan = b(0) - 1
        else
            zspan = b(0)
        end if
        
        delete(zz)
        delete(b)
        FirstTime = False
    end if

      ; Options for XY Plots
        opts_xy                         = res
        opts_xy@tiYAxisString           = "Altura (Km)"
        opts_xy@cnMissingValPerimOn     = True
        opts_xy@cnMissingValFillColor   = 0
        opts_xy@cnMissingValFillPattern = 11
        opts_xy@tmYLMode                = "Explicit"
        opts_xy@tmYLValues              = fspan(0,zspan,nz)                    ; Create tick marks
        opts_xy@tmYLLabels              = sprintf("%.1f",fspan(zmin,zmax,nz))  ; Create labels
        opts_xy@tiXAxisFontHeightF      = 0.020
        opts_xy@tiYAxisFontHeightF      = 0.020
        opts_xy@tmXBMajorLengthF        = 0.02
        opts_xy@tmYLMajorLengthF        = 0.02
        opts_xy@tmYLLabelFontHeightF    = 0.015
        opts_xy@PlotOrientation         = p_plane@Orientation

      ; Plotting options for wind
        opts_wv = opts_xy 
        opts_wv@FieldTitle = "Wind" ; overwrite Field Title 
        opts_wv@NumVectors = 40 ; density of wind barbs 
        opts_wv@vcGlyphStyle ="CurlyVectorly" 
        vector = wrf_vector(a,wks,u_plane,v_plane,opts_wv) 


      ; Plotting options for rh
        opts_tc               = opts_xy
        opts_tc@ContourParameters         = (/ -45., 10., 3 /)
        opts_tc@pmLabelBarOrthogonalPosF  = -0.07
        opts_tc@cnFillOn                  = True
    opts_tc@cnLinesOn         = False





      ; Plotting options for Pressure
        opts_p              = opts_xy
        opts_p@ContourParameters    = (/ 100.,1000.,50. /)
    opts_p@cnInfoLabelOn        = False

      ; Get the contour info for the rh and temp
    if ( LimitedExtent ) then
        contour_p   = wrf_contour(a,wks,p_plane(0:zmax_pos,:),opts_p)
        contour_vort    = wrf_contour(a,wks,tc_plane(0:zmax_pos,:),opts_tc)
    else
            contour_p   = wrf_contour(a,wks,p_plane,opts_p)
            contour_vort    = wrf_contour(a,wks,tc_plane,opts_tc)
    end if

      ; MAKE PLOTS         
        plot = wrf_overlays(a,wks,(/contour_vort,contour_p,vector/),pltres)

    if ( FirstTimeMap ) then

        lat_plane   = wrf_user_intrp2d(lat,plane,angle,opts)
        lon_plane   = wrf_user_intrp2d(lon,plane,angle,opts)
        vort500     = wrf_user_intrp3d(vort,p,"h",500.,0.,False)

        vort500         = vort500 * 100000.0
        vort500@description = "500 hPa Relative Vorticity"
        vort500@units       = "10^5 s^-1"

        mpres           = True
        mpres@mpGeophysicalLineColor      = "Black"
        mpres@mpNationalLineColor         = "Black"
        mpres@mpUSStateLineColor          = "Black"
        mpres@mpGridLineColor             = False
        mpres@mpGridAndLimbOn             = False
        mpres@mpLimbLineColor             = "Black"
        mpres@mpPerimLineColor            = "Black"
        mpres@mpGeophysicalLineThicknessF = 2.0
        mpres@mpGridLineThicknessF        = 2.0
        mpres@mpLimbLineThicknessF        = 2.0
        mpres@mpNationalLineThicknessF    = 2.0
        mpres@mpUSStateLineThicknessF     = 2.0

        lats    = (/ lat_start - 5.0, lat_end + 5.0 /)
        lons    = (/ lon_start - 10.0, lon_end + 10.0 /)

        loc     = wrf_user_ll_to_ij(a,lons,lats,True)
        x_start = loc(0,0) - 1 
        x_end   = loc(0,1) - 1 
        y_start = loc(1,0) - 1 
        y_end   = loc(1,1) - 1

        mpres@ZoomIn    = True
        mpres@Xstart    = x_start
        mpres@Xend      = x_end
        mpres@Ystart    = y_start
        mpres@Yend      = y_end

        pltres          = True
        pltres@FramePlot    = False

        if ( planview.eq."vort" ) then

            optsM               = res
            optsM@NoHeaderFooter        = True
            optsM@cnFillOn          = True
            optsM@cnLinesOn         = False
            optsM@lbTitleOn         = False
            optsM@cnLevelSelectionMode  = "ManualLevels"
            optsM@cnMaxLevelValF        = 20.0
            optsM@cnMinLevelValF        = -20.0
            optsM@cnLevelSpacingF       = 0.5

            contour = wrf_contour(a,wks2,vort500(y_start:y_end,x_start:x_end),optsM)
        else if( planview.eq."ter" ) then

            optsM               = res
            optsM@NoHeaderFooter        = True
            optsM@cnFillOn          = True
            optsM@cnLinesOn         = False
            optsM@lbTitleOn         = False
            optsM@cnLevelSelectionMode  = "ManualLevels"
            optsM@cnMaxLevelValF        = 6000.0
            optsM@cnMinLevelValF        = 0.0
            optsM@cnLevelSpacingF       = 100.0

         ;   contour = wrf_contour(a,wks2,ter(y_start:y_end,x_start:x_end),optsM)

        else
            print("INVALID PLANVIEW TYPE!!!")
        end if
        end if

      ;  plot    = wrf_map_overlays(a,wks2,(/contour/),pltres,mpres)

        lnres           = True
        lnres@gsLineThicknessF  = 3.0
        lnres@gsLineColor   = "Red"

        ;gsn_polyline(wks2,plot,(/lon_start,lon_end/),(/lat_start,lat_end/),lnres)
        
        frame(wks2)
        delete(lon_plane)
        delete(lat_plane)
        pltres@FramePlot = True

    end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP

end

