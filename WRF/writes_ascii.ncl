;;; escreveascii.ncl ;;;;;;;;;;;;;;;;;;.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 27 Aug 2016                                      ;
; Last modified  - 21 Apr 2016                                      ;
;                                                                   ;
; Observation    - Use get_ind.ncl to get the correct grid point.   ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/home/uesleisutil/NCL/loads.ncl"

begin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Open File                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  dir1         = "/home/uesleisutil/Documentos/Dissertação/Dados/" 
  a            = addfile(dir1+"coawst.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Choose local and variable                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 2.1. Choose betwenn 'florianopolis', 'torres', 'rio_grande'.
  loc = "florianopolis"
  ;loc = "torres"
  ;loc = "rio_grande"

; 2.2. Choose between 'temperatura', 'pressao' and 'vento'.
  ;var = "pressao"
  var = "temperatura"
  ;var = "vento"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Local set                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3.1. Florianopolis.
if (loc.eq."florianopolis")then 
  lat = 568
  lon = 320
end if

; 3.2. Torres.
if (loc.eq."torres")then 
lat = 535
lon = 304
end if

; 3.3. Rio Grande.
if (loc.eq."rio_grande")then 
lat = 485
lon = 236
end if 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Variable set                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 4.1. Temperatura 
if (var.eq."temperatura")then 
  var1     = wrf_user_getvar(a,"T2",-1)
  var2     = var1-273.15
  copy_VarAtts(var1, var2)
  var1_out = var2(:,lat,lon)
  asciiwrite("var.txt", var1_out)
end if

; 4.2. Pressao.
if (var.eq."pressao")then 
  var1     = wrf_user_getvar(a,"PSFC",-1)
  var2     = var1/100
  copy_VarCoords(var1, var2)
  var1_out = var2(:,lat,lon)
  asciiwrite("var.txt", var1_out)
end if

; 4.3. Velocidade do Vento.
if (var.eq."vento")then 
  uvm10 = wrf_user_getvar(a,"uvmet10",-1)
  u     = uvm10(0,:,:,:)
  v     = uvm10(1,:,:,:)
  vel   = sqrt(u^2+v^2)
  var1_out = vel(:,lat,lon)
  asciiwrite("var.txt", var1_out)
end if

end