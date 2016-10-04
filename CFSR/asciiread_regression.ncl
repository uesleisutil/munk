;;; asciiread_reression.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 04 Oct 2016                                      ;
; Last modified  - 04 Oct 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "/home/uesleisutil/NCL/loads.ncl"
begin

ncol  = 8
ntim  = numAsciiRow("/home/uesleisutil/Documentos/correl2.csv")
a = asciiread("/home/uesleisutil/Documentos/correl2.csv",(/ntim,ncol/),"float")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dia           = a(:,0)
pomerode      = a(:,1)
timbo         = a(:,2)
riodoscedros  = a(:,3)
majorgercino  = a(:,4)
angelina      = a(:,5)
fcl           = a(:,6)
tsm           = a(:,7)

y             = angelina
x             = fcl
y_name        = "Precipita"+cedil+""+atilde+"o Angelina"
x_name        = "Fluxo de Calor Latente"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Do the regression.                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 3.1. Calculate the regression coefficient (slope)    
rc    = regline(x,y)          ; slope                   
print(rc)


;************************************************
; 3.2. Create an array to hold both the original data
; and the calculated regression line   
;     ---------
;     y = mx+b 
;     m is the slope:       rc      returned from regline
;     b is the y intercept: rc@yave attribute of rc returned from regline
;************************************************
pltarry   = new ( (/2,ntim/), typeof(a), a@_FillValue)

pltarry(0,:) = y                                 ; use markers
pltarry(1,:) = rc*(x-rc@xave) + rc@yave          ; use solid line


anova = regline_stats(x,y)
anova_value = anova@r

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Resources.                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wks  = gsn_open_wks("png","regress") 
   
res                     = True                   ; plot mods desired
res@xyMarkLineModes     = (/"Markers","Lines"/)  ; choose which have markers
res@xyMarkers           = 16                     ; choose type of marker 
res@xyMarkerColor       = "red"                  ; Marker color
res@xyMarkerSizeF       = 0.008                  ; Marker size (default 0.01)
res@xyDashPatterns      = 1                      ; solid line 
res@xyLineThicknesses   = (/5,5/)                ; set second line to 2
res@tmYLFormat          = "f"                    ; not necessary but nicer labels 
res@tiYAxisString       = y_name
res@tiXAxisString       = x_name
res@trYMinF             = 0.   ; Limits for Y axis.  The limits
;res@trYMaxF             = 1000.  ; for the X axis will be different
res@tiMainString = "r: "+anova_value
plot  = gsn_csm_xy (wks,x,pltarry,res)           ; create plot

; 


txres               = True                     ; text mods desired
txres@txFontHeightF = 0.03                     ; font smaller. default big


;dum   = gsn_add_text(wks,plot,"r value: "+anova_value,x_anova,y_anova,txres) 
;draw(plot)
;frame(wks)        ; Advance frame
end