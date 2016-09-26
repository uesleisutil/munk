;*******************************************************************;
;* Script    - xy3.ncl                                             *;
;*                                                                 *;
;* Author    - Ueslei Adriano Sutil                                *;
;*                                                                 *;
;* Created   - 21 jul 2015                                         *;
;* Update    - 21 jul 2015                                         *;
;*                                                                 *;
;* About     - Drawing an XY plot with three different Y axes;     *;
;            - Drawing a custom legend inside an XY plot;          *;
;            - Maximizing the size of several different objects    *;
;              on a frame;                                         *;
;            - Maximizing plots after they've been created.        *;
;                                                                  *;
;* Input     - CFSR                                                *;
;* Variables - LH, SST, PSFC                                       *;
;*                                                                 *;
;*******************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, begin and open file                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.
load "/home/uesleisutil/NCL/loads.ncl"

begin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Open File                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  dir1         = "/home/uesleisutil/Documentos/Dissertação/Dados/" 
  a            = addfile(dir1+"coawst.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Read variables at first time step.                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times  = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)                ; number of times in the file
  times1 = wrf_user_getvar(a,"Times",-1)   ; get all times in the file
  time_3 = wrf_times_c(times1, 3)         ; yyyymmddhh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set time, coordinates and variables                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 
; 2.1. To calculate precipitation.
  lat1 = 115
  lat2 = 608
  lon1 = 372

  t1   = 17
  t2   = 16

  prec1     = wrf_user_getvar(a, "RAINC", -1)
  rainc_17  = prec1(t1,lat1:lat2,lon1)                                
  prec2     = wrf_user_getvar(a, "RAINNC", -1)
  rainnc_17 = prec2(t1,lat1:lat2,lon1)                                
  prec3     = wrf_user_getvar(a, "RAINSH", -1)
  rainsh_17 = prec3(t1,lat1:lat2,lon1)                           
  
  rainc_16  = prec1(t2,lat1:lat2,lon1)                                  
  rainnc_16 = prec2(t2,lat1:lat2,lon1)                           
  rainsh_16 = prec3(t2,lat1:lat2,lon1)   

  raint     = (rainc_17+rainnc_17+rainsh_17)-(rainc_16+rainnc_16+rainsh_16)
  
; 2.2. To calculate the wind divergence.
  u1     = wrf_user_getvar(a, "ua", t1)
  u2     = wrf_user_unstagger(u1, u1@stagger)
  u      = u2(0,:,:)
  v1     = wrf_user_getvar(a, "va", t1)
  v2     = wrf_user_unstagger(v1, v1@stagger)
  v      = v2(0,:,:)

  lat2d  = wrf_user_getvar(a,"lat",t1)
  lon2d  = wrf_user_getvar(a,"lon",t1) 
  lat    = lat2d(:,0) 
  lat3   = lat2d(:,0)
  lat4   = lat3(lat1:lat2)
  lon2   = lon2d(0,:)

  rv_1   = uv2vr_cfd(u,v,lat,lon2,3) 
  wrf_smooth_2d(rv_1, 5)
  
  rv_2   = rv_1(lat1:lat2,lon1)
  rv     = rv_2*10^4 

; 2.3. To calcula latent heat
  lh1    = wrf_user_getvar(a, "LH", t1)
  lh     = lh1(lat1:lat2,lon1)   
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Plot option                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  wks  = gsn_open_wks("png","xy")                         

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Resources                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  res = True
  res@vpHeightF = 0.5
  res@vpWidthF = 1.5
  res@xyLineThicknessF = 2.0

  res@tmXTOn = False ; Turn off right and top tick marks
  res@tmXBTickSpacingF = 2. 
  res@tmXBLabelFontHeightF = 0.03
  res@tmYLLabelFontHeightF = 0.03 
  res@tmYRLabelFontHeightF = 0.03

  res@gsnYRefLine           = 0.0             ; create a reference line  
  
  res@tmXMajorGrid = True ; implement y grid
  res@tmXMajorGridThicknessF = 0.5 ; 2.0 is default
  res@tmXMajorGridLineDashPattern = 15 ; select short dash lines

  res@tmXMajorGrid = True ; implement x grid 
  res@tmXMajorGridThicknessF = 0.5 ; 2.0 is default
  res@tmXMajorGridLineDashPattern = 15 ; select short dash lines


;4.1. Set SST resources;

  res1                          = res
  res1@gsnMaximize              = True
  res1@tiMainString             = ""
  res1@tiYAxisString            = " Daily Precipitation (mm)"
  res1@trYMaxF                  = 20
  res1@trYMinF                  = 0
  res1@xyLineThicknessF         = 5.0
  res1@xyLineColor              = "blue"                    ; t
  res1@tiYAxisFontColor         = "blue"

 ;4.2. Set SFCP resources; 

  res2                          = res
  res2@xyLineColor              = "green"                  ; u
  res2@tiYAxisString            = " Wind Divergence (10~S~-4~N~ s~S~-1~N~)"
  res2@trYMaxF                  = 6
  res2@trYMinF                  = -6
  res2@xyLineThicknessF         = 5.0
  res2@tiYAxisFontColor         = "green"

 ;4.3. Set LHF resources.

  res3                          = res 
  res3@xyLineColor              = "red"                  ; v
  res3@tiYAxisString            = " Latent Heat Flux(W s~S~-2~N~)"
  res3@trYMaxF                  = 600 
  res3@trYMinF                  = 0
  res3@amOrthogonalPosF         = 0.79                    ; Move "v" axis line to right a little.
  res3@xyLineThicknessF         = 5.0
  res3@tiYAxisFontColor         = "red"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Plot                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  plot = gsn_csm_xy3(wks,lat4,raint,rv,lh,res1,res2,res3)

;
; Maximize all of this output on the frame. The plot will be
; drawn and the frame advanced.
; 
  psres = True
  maximize_output(wks,psres)

end