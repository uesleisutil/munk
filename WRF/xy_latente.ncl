; 1.1. Prototype scripts.
  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin.
  
  begin

; 1.3. Open WRF output file.

  dir1 = "/home/daniela/Documents/Dissertação/Dados/WRF/" 
  a   = addfile(dir1+"wrfout_d01_2006-08-25_00:00:00","r")

  dir2 = "/home/daniela/Documents/Dissertação/Dados/CFSR/FluxodeCalorLatente/"
  b   = addfile(dir2 + "pgbh02.gdas.20060901-20060905.grb2.nc", "r")

  dir3 = "/home/daniela/Documents/Dissertação/Dados/OAFlux/"
  c   = addfile(dir3 + "lh_oaflux_2006.nc", "r")

t_wrf = 36
t_cfsr = 08
t_oaflux = 275

  lh1  = wrf_user_getvar(a, "LH", -1)
  lh_wrf    = lh1(t_cfsr,383,602:142)

  lh_cfsr  = b->LHTFL_L1(t_cfsr,{-37},{-60:-30})

  lh_oaflux = c->lhtfl(t_oaflux,{-37},{300:330})

  ;lon3  = wrf_user_getvar(a, "XLONG", -1)
  ;printVarSummary(lon3)
  lon2 = b->lon
  lon = lon2({-60:-30})
  ;lon  = lon3(t_wrf,383,602:142)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Plot option                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  wks  = gsn_open_wks("png","xy")                         

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Resources                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;4.1. Set WRF resources;

  res1                          = True
  res1@gsnMaximize              = True
  res1@tiMainString             = ""
  res1@tiYAxisString            = "WRF"
  res1@trYMaxF                  = -40
  res1@trYMinF                  = 500
  res1@xyLineThicknessF         = 5.0
  res1@xyLineColor              = "red"                    ; t

 ;4.2. Set CFSR resources; 

  res2                          = True
  res2@xyLineColor              = "green"                  ; u
  res2@tiYAxisString            = "CFSR"
  res2@trYMaxF                  = -40
  res2@trYMinF                  = 500
  res2@xyLineThicknessF         = 5.0

 ;4.3. Set OAFlux resources.

  res3                          = True
  res2@xyLineColor              = "green"                  ; u
  res2@tiYAxisString            = "OAFlux"
  res2@trYMaxF                  = -40
  res2@trYMinF                  = 500
  res2@xyLineThicknessF         = 5.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Plot                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  plot = gsn_csm_xy3(wks,lon,lh_wrf,lh_cfsr,lh_oaflux,res1,res2,res3)

;6.1. Legend Resources;

  lgres                         = True
  lgres@lgLineColors            = (/"red","green","blue"/)
  lgres@lgLineThicknessF        = 5
  lgres@lgMonoItemType          = "True"
  lgres@lgItemType              = "Lines"                 ; show lines only (default)
  lgres@lgLabelFontHeightF      = .09                     ; legend label font thickness
  lgres@vpWidthF                = 0.33                    ; width of legend (NDC)
  lgres@vpHeightF               = 0.070                    ; height of legend (NDC)
  lgres@lgPerimThicknessF       = 3.0                     ; thicken the box perimeter
  lgres@lgMonoDashIndex         = True 
  lgres@lgDashIndex             = 0

;  6.2. Legend itens;

  labels = (/" WRF"," CFSR"," OAFlux"/)
  nitems = dimsizes(labels)                               ; number of legend items

;6.3. Create legend;

  lbid   = gsn_create_legend(wks,nitems,labels,lgres)

;6.4. Use gsn_add_annotation to attach this legend to our existing plot.
; This way, if we resize the plot, the legend will stay with the
; plot and be resized automatically.

  amres  = True

;6.5. Set legend point 
;
;Point (0,0) is the dead center of the plot. Point (0,.5) is center,
;flush bottom. Point (0.5,0.5) is flush bottom, flush right.
;
  amres@amJust           = "BottomRight"                 ; Use bottom right corner of box
                                                         ; for determining its location.
  amres@amParallelPosF   = 0.3                           ; Move legend to right
  amres@amOrthogonalPosF = 0.75                           ; Move legend down.

  annoid = gsn_add_annotation(plot,lbid,amres)           ; add legend to plot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Maximize plot & end                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  
; Maximize these plots for PS or PDF output. If output is                    
; to an X11 window or an NCGM file, then this routine doesn't                
; do anything.                                                               
  
  psres = True                                                               
  maximize_output(wks,psres)                            ; calls draw and frame for you 

end