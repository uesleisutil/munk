;;; eof.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 13 Sep 2015                                      ;
; Last modified  - 13 Sep 2015                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, begin and open file                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

load "/home/ueslei/Documentos/NCL/scripts/loads.ncl"

; 1.2. Begin.
  
begin

; 1.3. Open WRF output file.

dir = "/home/ueslei/Documentos/Dissertação/Dados/COAWST/" 
a   = addfile(dir+"wrfout_d01_2006-08-27_00:00:00","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Choose eigenvalues, then select the variable                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 2.1. Eigenvalues.

neof   = 3

; 2.2. Variable.

x    = wrf_user_getvar(a,"SST",-1)             ; (time,lat,lon) ==> (29,60,180)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. EOF.                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 3.1. Reorder variable dimension.

X = x(south_north|:,west_east|:,Time|:)              ; Space x Time

; 3.2. Select WRF grid min-max.

lat2d = a->XLAT(0,:,:)
lon2d = a->XLONG(0,:,:)
latmin   = min(lat2d)
latmax   = max(lat2d)
lonmin   = min(lon2d)
lonmax   = max(lon2d)

; 3.3. Select EOF option.

optEof = True
eof    = eofunc_Wrap( X, neof, optEof)
eof_ts = eofunc_ts_Wrap( X, eof, False)

printVarSummary(eof)
printVarSummary(eof_ts)
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Workstation options.                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wks = gsn_open_wks("png","eof")
gsn_define_colormap(wks,"BlWhRe")     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Plot resources.                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dum                               = NhlNewColor(wks,0.7,0.7,0.7)    ; add gray to color table
plot                              = new(neof,graphic)               ; create graphic array, only needed if paneling.

res                               = True         
res@gsnDraw                       = False              ; don't draw yet
res@gsnFrame                      = False               ; don't advance frame yet
res@gsnSpreadColors               = True                ; spread out color table
res@gsnSpreadColorEnd             = -2                  ; don't use added gray
res@gsnAddCyclic                  = False               ; data not cyclic
res@mpMinLonF                     = lonmin              ; longitude oeste
res@mpMaxLonF                     = lonmax              ; longitude leste
res@mpMinLatF                     = latmin              ; latitude sul
res@mpMaxLatF                     = latmax              ; latitude norte
res@mpFillDrawOrder               = "PostDraw"

res@mpDataSetName                 = "Earth..4"           ; This new database contains
res@mpDataBaseVersion             = "MediumRes"          ; Medium optsolution database
res@mpOutlineOn                   = True                 ; Turn on map outlines
res@mpOutlineSpecifiers           = (/"Brazil:states"/)  
res@mpGridAndLimbOn               = False                ; Default is every 15 deg
res@mpProvincialLineColor         = "black"              ; States line color line
res@mpGeophysicalLineColor        = "black"              ; Contour map color line
res@mpNationalLineColor           = "black"              ; Continent  olor line
res@pmLegendOrthogonalPosF        = -0.99                ; Wind legend localization
res@pmLegendParallelPosF          = 1.0                  ; Wind legend localization
res@mpProvincialLineThicknessF    = 3                    ; State line thickness  
res@mpNationalLineThicknessF      = 3                    ; Continent line thickness
res@mpGeophysicalLineThicknessF   = 3.0
res@mpPerimOn                     = True
res@mpPerimLineTphicknessF        = 3.0                  
res@cnFillOn                      = True  
res@cnFillOn                      = True                 ; turn on color fill
res@cnLinesOn                     = True                 ; True is default
res@lbLabelBarOn                  = False                ; turn off individual lb's                            
res@cnMinLevelValF                = -0.01
res@cnMaxLevelValF                = 0.01
res@cnLevelSpacingF               = 0.001
;symMinMaxPlt(eof, 3, False, res)                        ; set symmetric plot min/max

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Plot panel resources.                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = True         ; add common colorbar
resP@lbLabelAutoStride   = True         ; auto stride on labels

resP@txString            = "COAWST Sea Surface Temperature EOF"
  
  do n=0,neof-1
     res@gsnLeftString  = "EOF "+(n+1)
     res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_contour_map_ce(wks,eof(n,:,:),res)
  end do
 
  gsn_panel(wks,plot,(/3,2/),resP)     ; draw all 'neof' as one plot

; ;*******************************************
; ; time series (principal component) plot
; ;*******************************************
;   eof_ts@long_name = "Amplitude"

; rts           = True
; rts@gsnDraw   = False       ; don't draw yet
; rts@gsnFrame  = False       ; don't advance frame yet
;  ;rts@gsnScale  = True        ; force text scaling               

; ; these four resources allow the user to stretch the plot size, and
; ; decide exactly where on the page to draw it.

; rts@vpHeightF = 0.40        ; Changes the aspect ratio
; rts@vpWidthF  = 0.85
; rts@vpXF      = 0.10        ; change start locations
; rts@vpYF      = 0.75        ; the plot

; rts@gsnYRefLine           = 0.              ; reference line   
; rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
; rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; ; panel plot only resources
; rtsP                     = True             ; modify the panel plot
; rtsP@gsnMaximize         = True             ; large format
      
;   resP@txString            = "WRF LH EOF"
;   do n=0,neof-1
;      rts@gsnLeftString  = "EOF "+(n+1)
;      rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
; ;  plot(n) = gsn_csm_xy (wks,x&Time,eof_ts(n,:),rts)
;   end do
; ;gsn_panel(wks,plot,(/neof,1/),rtsP)        ; draw all 'neof' as one plot

end