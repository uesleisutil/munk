;;; wrf_vimfc.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 02 Sep 2019                                      ;
; Last modified  - 02 Sep 2019                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/home/ueslei/NCL/loads.ncl"
begin

    merge_nc_output    = True
    delete_single_time = False

    ; Open files
    nc_file = addfile("/media/ueslei/Ueslei/INPE/PCI/Projetos/SC_2008/Outputs/normal/wrf.nc","r")

    times   = nc_file->XTIME 
    ntimes = dimsizes(times) 

        do i = 168,ntimes-1  
        ; Load variables.
        lon2d   = nc_file->XLONG(i,:,:)	     	;; Longitude
        lat2d   = nc_file->XLAT(i,:,:)		;; Latitude
        lat     = lat2d(:,0)			;; Xarray of latitudes
        lon     = lon2d(0,:)			;; Xarray of Longitudes
        psfc    = nc_file->PSFC(i,:,:)
        u_1     = wrf_user_getvar(nc_file,"ua",i)   	;; Surface Temp 
        v_1     = wrf_user_getvar(nc_file,"va",i)   	;; Surface Temp 
        mr      = nc_file->QVAPOR(i,:,:,:) ; The original unit of QVAPOR is kgkg-1
        hus     = mr/(1+mr)
        wrf_p   = nc_file->P(i,:,:,:)

        ; Vertical pressure layers for integration.
        user_lev = (/ 1000,975,950,925,900,875,850,825,800,775,750,725,700/)

        ; Calculates pressure layer thickness.
        dp = dpres_plevel(user_lev, psfc, 5000, 0)
        
        ; Store temporary variable.
        dt_sizes = dimsizes(wrf_p)
        l_0      = dt_sizes(0)
        l_1      = dt_sizes(1)
        l_2      = dt_sizes(2)
        var_u    = new((/dimsizes(user_lev),l_1,l_2/),float)
        var_v    = new((/dimsizes(user_lev),l_1,l_2/),float)
        
        ; Calculate moisture fluxes in a new variable.  
        mfv = u_1*hus
        mfu = v_1*hus  

        ; Loop over pressure levels.
        do ii=0,dimsizes(user_lev)-1
            var_u(ii,:,:) = wrf_interp_3d_z(mfv,wrf_p,user_lev(ii))
            var_v(ii,:,:) = wrf_interp_3d_z(mfu,wrf_p,user_lev(ii))
        end do

        ; Calculate the fluxes at every layer.
        u = var_u*dp        
        v = var_v*dp

        ; U and V with the gravity aceleration.
        mf_u      = dim_sum_n(u,0)/9.81
        mf_v      = dim_sum_n(v,0)/9.81
        mf_u!0    = "lat"
        mf_u!1    = "lon"
        mf_v!0    = "lat"
        mf_v!1    = "lon"

        ; Integrate fluxes from top to bottom.
        dim_mf_uv  = dimsizes(mf_u)
        vimfc      = uv2dv_cfd(mf_v,mf_v,lat,lon, 2)

        ; Store VIMFC in new variable.
        vimfc!0 = "Times"
        vimfc!0 = "lat"
        vimfc!1 = "lon"
        vimfc@Name = "Integated Horizontal Moisture Flux"
    
        ; Create new VIMFC nc files.
        create_nc               = addfile("vimfc_"+i+".nc","c")
        create_nc->vimfc        = vimfc
        file_meta               = True            ; assign file attributes
        file_meta@title         = "VIMFC calculate from WRF output for SC_2008 project"
        file_meta@Contact       = "Ueslei A. Sutil (ueslei.sutil (at) inpe.br)"
        file_meta@creation_date = systemfunc ("date")
        file_meta@Conventions   = "CF"
        fileattdef(create_nc, file_meta)

    end do
    if merge_nc_output .eq. True then
        a = systemfunc("cdo cat vimfc_* vimfc.nc")
    end if
    if delete_single_time .eq. True then
        b = systemfunc("rm -rf vimfc_*")
    end if
end
