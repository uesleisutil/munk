;;; xy_graph.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 15 Nov 2015                                      ;
; Last modified  - 15 Nov 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, begin and open file                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.
load "/home/uesleisutil/NCL/loads.ncl"

begin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Open File                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  dir1 = "/home/uesleisutil/Documentos/Dissertação/Dados/" 
  a    = addfile(dir1+"cfsr_div.nc","r")
  b    = addfile(dir1+"cmorph_merged.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set time, coordinates and variables                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 2.1. Set time and coordinates.
  t1         = 10
  t2         = 01

  lat1       = -50
  lat2       = -25
  lon1       = -45
  lon_cmorph = 315


; 2.2. Set Latent Heat Flux.
  lh = a->LHTFL_L1(t1,{lat1:lat2},{lon1})

; 2.3. Set Precipitation.  
  raint = b->mmw_precip(t2,{lat1:lat2},{lon_cmorph})

; 2.4. Set Wind Divergence.
  u      = a->U_GRD_L103
  v      = a->V_GRD_L103
  lon    = a->lon
  lat    = a->lat
  rv_1   = uv2vr_cfd(u,v,lat,lon,3) 
  copy_VarCoords(u, rv_1)

  rv_2   = rv_1(t1,{lat1:lat2},{lon1})
  rv     = rv_2*10^4

  

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

  plot = gsn_csm_xy3(wks,lh&lat,raint,rv,lh,res1,res2,res3)

;
; Maximize all of this output on the frame. The plot will be
; drawn and the frame advanced.
; 
  psres = True
  maximize_output(wks,psres)

end