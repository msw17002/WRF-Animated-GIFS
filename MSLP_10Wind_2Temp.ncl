;----------------------------------------------------------------------
; wrf_nogsn_5.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using wrf_xxxx scripts to plot WRF-ARW data
;   - Overlaying line contours, filled contours, and vectors on a map
;----------------------------------------------------------------------
; This script is meant to show the difference between plotting WRF
; data using wrf_xxx scripts, and using gsn_csm_xxx scripts.
;
; See wrf_gsn_5.ncl for an example of using gsn_csm_contour_map to
; plot WRF data.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
; Printing PNG names
Loop = (/"00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99"/)
Path = "/shared/airmg/UMMUL/WRFv4.1.3/offshore/" 
;"/shared/airmg/MIKE/WRFv4.1.3/Build_WRF/DATA/NAM12k_2004/2012102500_2012103100/Testing_Domains/Domain_07/wrfout_files/wrfprd/"
; List all files
;Domain = (/"1","2","3","4"/)
do j=0,4-1 
Domain = tostring(j+1)
	NC_Files = systemfunc("ls "+Path+"*wrfout_d0"+Domain+"*")
	; Number of simulated hours 
	hours = dimsizes(NC_Files)
	; Loop through all files
	do i=0,hours-1
  		filename = NC_Files(i)
  		a = addfile(filename+".nc","r")

;---Read several WRF variables at first time step
		  it  = 0
		  slp = wrf_user_getvar(a,"slp",it)   ; sea level pressure
		  ;print("Hour "+i+" Min. MSLP "+min(slp))
		  wrf_smooth_2d( slp, 3 )             ; smooth slp
		  tc  = wrf_user_getvar(a,"T2",it)    ; 3D temperature
		  u   = wrf_user_getvar(a,"U10",it)    ; 3D U at mass points
		  v   = wrf_user_getvar(a,"V10",it)    ; 3D V at mass points

;---Now get the lowest (bottommost) level
		  nl  = 0
		  tc2 = tc(:,:)
		  u10 = u(:,:)
		  v10 = v(:,:)
		  print("Hour "+i+" Max. 10m Wind Speed "+max((u10^2+v10^2)^0.5))

		  tf2 = tc2-273.15                    ; Convert temperature to Fahrenheit
		  u10 = u10*1.94386                    ; Convert wind into knots
		  v10 = v10*1.94386
;tc,tc2,tf2,a,
;---Change the metadata
		  tf2@description = "Surface Temperature"
		  tf2@units       = "degC"
		  u10@units       = "kts"
		  v10@units       = "kts"

		  wks = gsn_open_wks("png","HR_"+Loop(i))

;---Set common resources
		  res                = True

;---Temperature filled contour plot
		  tf_res                   = res                         
		  tf_res@cnFillOn          = True  
		  tf_res@ContourParameters = (/ -40, 40, 2./)
                  ;tf_res@cnFillPalette     = "matlab_hsv"

		  contour_tf = wrf_contour(a,wks,tf2,tf_res)

;---SLP line contour plot
		  slp_res                                = res         
		  slp_res@cnLineColor                    = "NavyBlue"
		  slp_res@cnHighLabelsOn                 = True
		  slp_res@cnLowLabelsOn                  = True
		  slp_res@ContourParameters              = (/ 900, 1100, 4 /)
		  slp_res@cnLineLabelBackgroundColor     = -1
		  slp_res@gsnContourLineThicknessesScale = 2.0

		  contour_psl = wrf_contour(a,wks,slp,slp_res)

;---Wind vector plot
		  vec_res            = res         
		  vec_res@FieldTitle = "Wind"       ; overwrite Field Title
		  vec_res@NumVectors = 47           ; density of wind barbs
		  vector = wrf_vector(a,wks,u10,v10,vec_res)

;---Control appearance of map.
		  pltres                            = res
		  pltres@PanelPlot		    = res

                  mpres                             = res
		  mpres@mpOutlineOn                 = False
		  mpres@mpFillOn                    = False

		  usa_states_shp_path        = "/shared/airmg/MIKE/WRFv4.1.3/NCL_Script/Shapefiles/USA_States_5m/cb_2016_us_state_5m.shp"
	          usa_counties               = "/shared/airmg/MIKE/WRFv4.1.3/NCL_Script/Shapefiles/USA_Counties_5m/cb_2016_us_county_5m.shp"
		  canada_shp_path            = "/shared/airmg/MIKE/WRFv4.1.3/NCL_Script/Shapefiles/Canada/lpr_000b16a_e.shp"

		  lnres_nat                  = True
		  lnres_nat@gsLineColor      = "Black"
		  lnres_nat@gsLineThicknessF = 2.0

                  lnres_reg                  = True
                  lnres_reg@gsLineColor      = "gray25"
                  lnres_reg@gsLineThicknessF = 0.5

;---Overlay plots on map and draw.
         ov         = wrf_map_overlays(a,wks,(/contour_tf,contour_psl,vector/),pltres,mpres)
         usa_id     = gsn_add_shapefile_polylines(wks,ov,usa_states_shp_path,lnres_nat)
         can_id     = gsn_add_shapefile_polylines(wks,ov,canada_shp_path,lnres_nat)
	 usa_cnt_id = gsn_add_shapefile_polylines(wks,ov,usa_counties,lnres_reg)
	 draw(ov)
	 frame(wks)
		 end do
GIF_File = systemfunc("convert -delay 50 -loop 0 *.png MSLP_10Wind_2Temp_d0"+Domain+".gif")
delete([/NC_Files,a,slp,u,v,u10,v10,tc,tc2,tf2/])
end do
Clean    = systemfunc("rm *.png")
end
