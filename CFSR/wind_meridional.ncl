;;; wind_meridional.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 08 Jun 2015                                      ;
; Last modified  - 08 Jun 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts and begin                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
; 1.1. Prototype scripts
  
  load "/home/daniela/Documents/Dissertação/loads.ncl"

; 1.2. Begin.

  begin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Open file and Variables and set day                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Program Starts!")

  dir            = "/home/daniela/Documents/Dissertação/Dados/CFSR/WindComponents"
  f              = addfile(dir + "/pgbh01.gdas.20060901-20060905.grb2.nc","r")
    
  u              = f->V_GRD_L100
  u!0            = "time"                    
  u!1            = "lev"                     
  u!2            = "lat"                     
  u!3            = "lon" 
  u@units        = "hpa"
  u&lev@units    = "hpa"
   
  dia1           = (/"Dia 01 00Z","Dia 01 06Z", "Dia 01 12Z", "Dia 01 18Z", "Dia 02 00Z", "Dia 02 06Z", "Dia 02 12Z", "Dia 02 18Z", "Dia 03 00Z", "Dia 03 06Z", "Dia 03 12Z", "Dia 03 18Z", "Dia 04 00Z", "Dia 04 06Z", "Dia 04 12Z", "Dia 04 18Z", "Dia 05 00Z", "Dia 05 06Z", "Dia 05 12Z", "Dia 05 18Z"/)
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Resources                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  print("Setting resources!")
  res                      = True                 ; plot mods desired

  res@cnLevelSelectionMode = "ManualLevels"       ; manually select levels
  res@cnLevelSpacingF      = 5.0                  ; contour spacing
  res@cnMinLevelValF       = -60.                 ; min level
  res@cnMaxLevelValF       =  60.                 ; max level
  res@cnLineLabelsOn       = True                 ; turn on line labels
  res@cnFillOn             = True                 ; turn on color fill
  res@gsnMajorLatSpacing   = 10
  res@gsnMajorLonSpacing   = 5
  res@gsnRightString       = "m s~S~-1~N~"
  res@gsnLeftString        = " "
  res@tiYAxisString        = "Press"+atilde+"o (hPa)"
  ;res@txString             = "Altura (km)" Alterado na função gsn_csm
  res@lbLabelAngleF        = 90.0
  res@gsnSpreadColors      = True                 ; use full range of map
  res@lbLabelAutoStride    = True                 ; optimal labels
  res@trXReverse            = True 
; note u is already on pressure levels. If this were model data, it
; would be necessary to interpolate from the hybrid coordinates to 
; pressure levels.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Time loop, set file attributes and plot day, plot & end        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 5.1. Time loop.  
  do it = 0,19
  print("Working on time: " + it )

; 5.2. Set file attributes.

  wks   = gsn_open_wks ("png", "zonal"+it )           ; open workstation
  gsn_define_colormap(wks,"BlWhRe")                   ; choose colormap

; 5.3. Plot day .
  
  res@gsnCenterString          = dia1(it)

; 5.4. Plot
  
  plot  = gsn_csm_pres_hgt(wks, u(it,:,{-36},{-65:-30}) , res )   ; place holder
  end do

; 5.5. End.
  print("Done!")
end