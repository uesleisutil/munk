;;; skewt.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 16 Jun 2015                                      ;
; Last modified  - 01 Feb 2016                                      ;
;                                                                   ;
; PS: For southern hemisphere change the localOpts@hemisphere="SH"  ;
;     in skewt_func.ncl                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, begin and open file                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin
  
  begin

; 1.3. Read data.

  dir  = "/home/daniela/Documents/Dissertação/Dados"

  a   = addfile(dir+"/cfsr_skewt.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set lat/lon and variables                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 2.1. Lat lon.

  lat = -36
  lon = 305

; 2.2. Variables.

  tc1 = a->TMP_L100(0,:,{lat},{lon})
  tc  = tc1-273.15 
  copy_VarCoords(tc1, tc)

  tk  = a->TMP_L100(0,:,{lat},{lon})
  rh  = a->R_H_L100(0,:,{lat},{lon})
  z  = a->HGT_L100(0,:,{lat},{lon})    
  v = a->V_GRD_L100(0,:,{lat},{lon})
  u = a->U_GRD_L100(0,:,{lat},{lon})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Calculate dew point, wind speed & direction and pressure       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 3.1. Calc dew point.

  tdc1  = dewtemp_trh(tk,rh) 
  tdc   = tdc1-273.15
  copy_VarCoords(tdc1, tdc)

; 3.2. Calc wind speed & direction

  wspd = sqrt(u^2 + v^2)
  wdir = wind_direction(u,v,0)

; 3.3. Pressure

  p1 = b->HGT_L100(0,:,{lat},{lon})
  p = p1&level0
  copy_VarCoords(p1, p)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Create plots                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  wks  = gsn_open_wks ("png", "skewt")

  skewtOpts                 = True
  skewtOpts@DrawColAreaFill = True    ; default is False
  skewtOpts@tiMainString    = " " 

  dataOpts                  = False    ; options describing data and ploting

  skewt_bkgd = skewT_BackGround (wks, skewtOpts)
  ;skewt_data = skewT_PlotData   (wks, skewt_bkgd,p,tc,tdc,z, wspd,wdir, dataOpts)
  ;;draw (skewt_bkgd)
  ;draw (skewt_data)
  ;frame(wks)

  dataOpts           = True     ; options describing data and ploting
  dataOpts@Wthin     = 3        ; plot every n-th wind barb

 ;skewtOpts@tiMainString    = "ATS Rawindsonde: degC + Thin wind" 
 ;skewtOpts@DrawFahrenheit  = False   ; default is True

  skewt_bkgd = skewT_BackGround (wks, skewtOpts)
  skewt_data = skewT_PlotData   (wks, skewt_bkgd,p,tc,tdc,z, wspd,wdir, dataOpts)

  draw (skewt_bkgd)
  draw (skewt_data)
  frame(wks)

 end