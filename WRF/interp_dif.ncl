;*******************************************************************;
;* Script    - interp.ncl                                          *;
;*                                                                 *;
;* Author    - Regiane Moura                                       *;
;*                                                                 *;
;* Created   - 11 set 2015                                         *;
;* Update    - 11 set 2015                                         *;
;*                                                                 *;
;* About     - This program is a script that will interp a series  *;
;*             of variables from WRF and COAWST to GHRSST and      *;
;*             QuikSCAT data in order to make maps.                *;
;*******************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; 1.1. Prototype scripts.

   load "/home/ueslei/Documentos/NCL/scripts/loads.ncl"
 
  ; 1.2. Begin.

   begin

  ; 1.3. Files.

   dir1 = "/home/ueslei/Documentos/Dissertação/Dados/WRF/"
   a    = addfile(dir1+"wrfout_d01_2006-09-01_00:00:00","r")

   dir2 = "/home/ueslei/Documentos/Dissertação/Dados/COAWST/"
   b    = addfile(dir2+"wrfout_d01_2006-09-01_00:00:00","r")

   dir3 = "/home/ueslei/Documentos/Dissertação/Dados/GHRSST/"
   c    = addfile(dir3+"20060901_v2.nc","r")

   dir4 = "/home/ueslei/Documentos/Dissertação/Dados/QUIKSCAT/"
   d    = addfile(dir4+"200609010000-200609020000_v2.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Model coordinates and landmask and isolate lat & lon           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; 2.1. Coordinates.

   nl0       = 772       ; lat 15S   - arquivo 899 x 745
   nl1       = 112       ; lat 50S  

   ml0       = 65        ; lon 65W
   ml1       = 679       ; lon 25W

 ; 2.2. Landmask.

   lsm       = a->LANDMASK(0,nl1:nl0,ml0:ml1)

   lat2d     = a->XLAT(0,nl1:nl0,ml0:ml1)
   lon2d     = a->XLONG(0,nl1:nl0,ml0:ml1)      
   
 ; 2.3. Isolate lat/lon components of mass coordinate system and label/establish them in proper arrays

   lat       = lat2d(:,0)
   lon       = lon2d(0,:)
   lat@units = "degrees_north"
   lon@units = "degrees_east"
   lat!0     = "south_north"
   lon!0     = "west_east"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Creates SST Latitude and Longitude for WRF, then interpolate.  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  sst                   = a->SST(0,nl1:nl0,ml0:ml1)
  sst                   = sst-273.16
  sst1                  = mask(sst,lsm.ge.1,False)   ; mask
  copy_VarCoords(sst, sst1)

  south_north           = fspan(-50,-15,661)         ; calculate x values
  south_north@long_name = "south_north"
  south_north@units     = "degree_north"
  sst1&south_north      = south_north          

  west_east             = fspan(-65,-25,615)         ; lon
  west_east@long_name   = "west_east"
  west_east@units       = "degree_east"
  sst1&west_east        = west_east          
 
  fiCyclicX             = True  

  xo                    = fspan(-65,-25,281)         ; informações de lat/lon obtidas do arquivo original, 144 e 73 = resolução
  yo                    = fspan(-50,-15,81)         ;  espacial do ncep que correspondem a um domínio de 2,5lat x 2,5lon

  fo                    = 0

  sst1_interp           = linint2_Wrap(lon,lat,sst1,fiCyclicX,xo,yo,fo)

  sst1_interp!0         = "south_north"
  sst1_interp!1         = "west_east"
  south_north@units     = "degree_north"
  west_east@units       = "degree_east"



  delete([/sst,sst1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Creates SST Lat and Long for COAWST, then interpolate          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  sst                   = b->SST(0,nl1:nl0,ml0:ml1)
  sst                   = sst-273.16
  sst1                  = mask(sst,lsm.ge.1,False)    
  copy_VarCoords(sst, sst1)

  south_north           = fspan(-50,-15,661)         ; calculate x values        
  south_north@long_name = "south_north"
  south_north@units     = "degree_north"
  sst1&south_north      = south_north          

  west_east             = fspan(-65,-25,615)         ; lon        
  west_east@long_name   = "west_east"
  west_east@units       = "degree_east"
  sst1&west_east        = west_east          

  sst2_interp           = linint2_Wrap(lon,lat,sst1,fiCyclicX,xo,yo,fo)
    sst2_interp!0       = "south_north"       
    sst2_interp!1       = "west_east"
    south_north@units   = "degree_north"
    west_east@units     = "degree_east"

  delete([/sst,sst1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Set GHRSST.                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  sstg                 = short2flt(c->analysed_sst(0,{-50:-15},{295:335}))
  sst1                 = sstg(lon|:, lat|:)
  sst                  = sst1-273.16
 copy_VarCoords(sst1, sst)

;  sst = sst(::-1,:)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Creates Wind Lat and Long for WRF, then interpolate            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  u                     = a->U10(0,nl1:nl0,ml0:ml1)  
  v                     = a->V10(0,nl1:nl0,ml0:ml1)

  u1                    = mask(u,lsm.ge.1,False)     
  copy_VarCoords(u, u1)
  v1                    = mask(v,lsm.ge.1,False)     
  copy_VarCoords(v, v1)

  south_north           = fspan(-50,-15,661)         ; calculate x values         
  south_north@long_name = "south_north"
  south_north@units     = "degree_north"
  u1&south_north        = south_north          
  v1&south_north        = south_north 

  west_east             = fspan(-65,-25,615)         ; lon        
  west_east@long_name   = "west_east"
  west_east@units       = "degree_east"
  u1&west_east          = west_east          
  v1&west_east          = west_east        

  xow                   = fspan(-65,-25,81)        
  yow                   = fspan(-50,-15,62)         
    

  u1_interp             = linint2_Wrap(lon,lat,u1,fiCyclicX,xow,yow,fo)
  u1_interp!0           = "south_north"
  u1_interp!1           = "west_east"
  south_north@units     = "degree_north"
  west_east@units       = "degree_east"

  v1_interp             = linint2_Wrap(lon,lat,v1,fiCyclicX,xow,yow,fo)
  v1_interp!0           = "south_north"
  v1_interp!1           = "west_east"
  south_north@units     = "degree_north"
  west_east@units       = "degree_east"

  delete([/u,v,u1,v1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Creates Wind Lat and Long for COAWST, then interpolate            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  u                     = b->U10(0,nl1:nl0,ml0:ml1)  
  v                     = b->V10(0,nl1:nl0,ml0:ml1)

  u1                    = mask(u,lsm.ge.1,False)    
  copy_VarCoords(u, u1)
  
  v1                    = mask(v,lsm.ge.1,False)   
  copy_VarCoords(v, v1)

  south_north           = fspan(-50,-15,661)       
  south_north@long_name = "south_north"
  south_north@units     = "degree_north"
  u1&south_north        = south_north          
  v1&south_north        = south_north 

  west_east             = fspan(-50,-25,615)             
  west_east@long_name   = "west_east"
  west_east@units       = "degree_east"
  u1&west_east          = west_east          
  v1&west_east          = west_east         

  xow                   = fspan(-65,-25,81)        
  yow                   = fspan(-50,-15,62)         

  u2_interp             = linint2_Wrap(lon,lat,u1,fiCyclicX,xow,yow,fo)
  u1_interp!0           = "south_north"
  u1_interp!1           = "west_east"
  south_north@units     = "degree_north"
  west_east@units       = "degree_east"

  v2_interp             = linint2_Wrap(lon,lat,v1,fiCyclicX,xow,yow,fo)
  v2_interp!0           = "south_north"
  v2_interp!1           = "west_east"
  south_north@units     = "degree_north"
  west_east@units       = "degree_east"

  delete([/u,v,u1,v1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Set QuikSCAT zonal and meridional components.                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  u = short2flt(d->zonal_wind_speed({-50:-15},{295:335}))
  v = short2flt(d->meridional_wind_speed({-50:-15},{295:335}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Workstation options.                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  wks_type = "png"
; wks_type@wkWidth = 2500
; wks_type@wkHeight = 2500       

  wks      = gsn_open_wks(wks_type,"plt_wsst_3")
  gsn_define_colormap(wks, "MPL_jet")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Set differences between the datas.                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ud1 = (u1_interp-u)              ; U difference between WRF and QuikSCAT
vd1 = (v1_interp-v)              ; V difference between WRF and QuikSCAT

ud2 = (u2_interp-u)              ; U difference between COAWST and QuikSCAT
vd2 = (v2_interp-v)              ; V difference between COAWST and QuikSCAT

ud3 = (u1_interp-u2_interp)      ; U difference between WRF and COAWST
vd3 = (v1_interp-v2_interp)      ; V difference between WRF and COAWST

printVarSummary(sst1_interp)
printVarSummary(sst)
sstd1 = (sst1_interp-sst)        ; SST difference between WRF and GHRSST
sstd2 = (sst2_interp-sst)        ; SST difference between COAWST and GHRSST
sstd3= (sst1_interp-sst2_interp) ; SST difference between WRF and COAWST


copy_VarCoords(u1_interp, ud1)
copy_VarCoords(v1_interp, vd1)

copy_VarCoords(u2_interp, ud2)
copy_VarCoords(v2_interp, vd2)

copy_VarCoords(u2_interp, ud3)
copy_VarCoords(v2_interp, vd3)

copy_VarCoords(sst1_interp, sstd1)
copy_VarCoords(sst2_interp, sstd2)
copy_VarCoords(sst1_interp, sstd3)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 11. Resources for.                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; 11.1. Create plots.

   plot = new(3,graphic) 

 ; 11.2. Global Resources.

   res                           = True
   res@gsnDraw                   = False             ; don't draw
   res@gsnFrame                  = False             ; don't advance frame

   res@lbLabelBarOn              = False
   res@lbLabelAutoStride         = True              ; optimal label stride

   res@gsnScalarContour          = True              ; contours desired
   res@cnFillOn                  = True  
   res@cnLinesOn                 = False             ; turn off contour lines
   res@cnLineLabelsOn            = False             ; turn off contour line labels
   res@cnLevelSelectionMode      = "ManualLevels"    ; set manual contour levels
   res@cnMinLevelValF            = 0.                ; set min contour level
   res@cnMaxLevelValF            = 10               ; set max contour level
   res@cnLevelSpacingF           = 0.5                 ; set contour spacing
   res@cnInfoLabelOn             = False             ; turn off contour label

   res@vcRefMagnitudeF           = 10.0              ; define vector ref mag
   res@vcRefAnnoString1          = "Vento: 10 m s~S~-1~N~"
   res@vcRefLengthF              = 0.047             ; define length of vec ref
   res@vcRefAnnoOrthogonalPosF   = 0.165
   res@vcRefAnnoParallelPosF     = 0.100
   res@vcRefAnnoFontHeightF      = 0.015
   res@vcRefAnnoOn               = True

   res@gsnLeftString             = " " 
   res@gsnRightString            = " "               ; "~" is txFuncCode
   res@vcMinDistanceF            = 0.03
   res@vcGlyphStyle              = "CurlyVector"     ; turn on curley vectors
   res@vcLineArrowColor          = "Black"           ; change vector color
   res@vcLineArrowThicknessF     = 2.5               ; change vector thickness

 ; 11.5. Plot 1 Resources.

   res1                          = res
   res1@gsnCenterString          = "WRF minus COAWST"
   res1@vcRefAnnoOn              = False

 ; 11.6. Plot 2 Resouces.

   res2                          = res
   res2@gsnCenterString          = "WRF minus Satellite"
   res2@vcRefAnnoOn              = True

  ; 11.7. Plot 3 Resources.

   res3                          = res
   res3@gsnCenterString          = "COAWST minus Satellite"
   res3@vcRefAnnoOn              = False

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 12. Plots.                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  plot(0) = gsn_csm_vector_scalar(wks,ud3,vd3,sstd3,res1) ; difference between WRF and COAWST
  plot(1) = gsn_csm_vector_scalar(wks,ud1,vd2,sstd1,res2) ; difference between WRF and Satellite
  plot(2) = gsn_csm_vector_scalar(wks,ud2,vd2,sstd2,res3) ; difference between COAWST and Satellite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 12. Panel resources, plot & end.                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; 12.1. Panel Resources.

   resP                          = True
   resP@gsnPanelLabelBar         = True                 ; barra de cores igual p todas
   resP@gsnPanelFigureStrings    = (/"a","b","c", "d", "e", "f"/) ; add strings to panel
   resP@amJust                   = "TopLeft"            ; posição das letras ==> a) b) etc
   resP@lbLabelFontHeightF       = 0.001                ; tamanho dos gsnPanelFigureStrings (a,b,c,d...)
   resP@lbLabelFontHeightF       = 0.010
   resP@lbTitleFontHeightF       = 1.015                 ; make title smaller
   resP@lbTitleFontThicknessF    = 1
   resP@pmLabelBarOrthogonalPosF = -0.015
   resP@pmLabelBarParallelPosF   = 0.060
   resP@pmLabelBarWidthF         = 0.3
   resP@pmLabelBarHeightF        = 0.049 
   resP@lbTitleOn                = True
   resP@lbTitleString            =  "Temperatura da Superf"+iacute+"cie do mar (~S~o~N~C)"
   resP@lbTitlePosition          = "Top"
   resP@lbTitleFontHeightF       = 0.009

   ;resP@gsnPanelRowSpec         = True                  ; painéis complexos
   resP@gsnPanelCenter           = True                  ; novo comando ;-) - para centralizar, se for false ele alinha para esquerda
   resP@txString                 = "01/09/2006"

 ; 12.2. Plot.

   gsn_panel(wks,plot,(/1,3/),resP)              ; now draw as one plot

 ; 12.3. End.

   end
    
    















