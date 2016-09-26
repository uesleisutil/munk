; vertical_velocity.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author: Ueslei Adriano Sutil                                      ;
; Created: 06 October 2015                                          ;  
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, begin and open file                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin. 

  begin



  dir = "/home/daniela/Documents/Dissertação/Dados/WRF/" 
  a   = addfile(dir+"wrfout_d01_2006-08-27_00:00:00","r")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Extract time variables.                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 times  = wrf_user_getvar(a,"times",-1) 
 ntimes = dimsizes(times)              

 times1 = wrf_user_getvar(a,"Times",-1)
 time_3 = wrf_times_c(times1, 3)                 ; yyyymmddhh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Loop and extract variables                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 3.1. Extract variables, transform Pa to hPa then do copyvacoords.

 v    = wrf_user_getvar(a, "va", 28)
 w2   = wrf_user_getvar(a, "wa", 28)
 p    = wrf_user_getvar(a, "p", 28)
 tk   = wrf_user_getvar(a, "tk", 28)

  wrf_smooth_2d( v, 40 )             ; smooth slp
  wrf_smooth_2d( w2, 40 )             ; smooth slp
  wrf_smooth_2d( p, 40 )             ; smooth slp
  wrf_smooth_2d( tk, 40 )             ; smooth slp
 


; 3.2. Do loop.

 ;do it = 30,34
 ;print("Working on time: " + times(it))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Define Omega (Pa/s).                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 4.1. Define rho (287.04 is the product of the Boltzmann constant and the Avogadro constant (R)).

 w = w_to_omega(w2, p, tk)
 

 w3 =  w*50

 w1 = w3(:,::-1,:)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Define lat/lon and write data information                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 5.1. Define lat lon.

lat2d = a->XLAT(0,:,0)
lon2d = a->XLONG(0,0,:)

; 5.2. Define variables attributes.

copy_VarCoords(w2, w1)


w!0            = "lev"
w!1            = "lat"
w!2            = "lon"
w&lat          = lat2d
w&lon          = lon2d
w&lev          = fspan(1050,50,40)
w@long_name    = "pressure"
w@units        = "hPa"
w&lev@units    = "hPa"

v!0            = "lev"
v!1            = "lat"
v!2            = "lon"
v&lat          = lat2d
v&lon          = lon2d
v&lev          = fspan(1050,50,40)
v@units        = "m s-1"
v@long_name    = "pressure"
v&lev@units    = "m s-1"

w1!0           = "lev"
w1!1           = "lat"
w1!2           = "lon"
w1&lat         = lat2d
w1&lon         = lon2d
w1&lev         = fspan(1050,50,40)
w1@units       = "hpa"
w1@long_name   = "pressure"
w1&lev@units   = "hpa"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Workstation.                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 wks = gsn_open_wks("png","fcell1")

 gsn_define_colormap(wks,"NCV_blu_red")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Set resources.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 res                          = True
 res@cnLinesOn                = False
 res@cnFillOn                 = True
 res@vcRefLengthF             = 0.04
 res@vcGlyphStyle             = "CurlyVector"          
 res@vcRefAnnoOn              = True           
 res@vcRefAnnoOrthogonalPosF  = 0.0
 res@vcRefAnnoParallelPosF    = 0.6     
 res@vcLineArrowThicknessF    = 5
 res@vcRefAnnoString2On       = False   
 res@vcRefAnnoPerimOn         = True     
 res@vcMinDistanceF           = 0.03  
 res@vcRefMagnitudeF          = 15.0               ; Reference vector magnitude
 res@vcRefAnnoString1         = "Vento: 15 m s~S~-1~N~"
 ;res@vcMinFracLengthF         = 1                 ; "Broken vector"
 res@cnLevelSelectionMode     = "ManualLevels"
 res@cnLevelSpacingF          =  0.059
 res@cnMinLevelValF           = -1.09
 res@cnMaxLevelValF           =  1.09
 res@lbLabelStride             = 1
 res@lbLabelAngleF            = 90.0
 res@vcMapDirection = False
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Plot, end do and end.                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 8.1. Plot.

 plot = gsn_csm_pres_hgt_vector(wks,w({1000:250},333,:),v({1000:250},333,:), w1({1000:250},333,:),res)  

; 8.2. End do.

;end do

; 8.3. End.

 end