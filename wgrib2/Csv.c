/******************************************************************************************
 Copyright (C) 2008 Niklas Sondell, Storm Weather Center
 This file is part of wgrib2 and could be distributed under terms of the GNU General Public License

*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "grb2.h"
#include "wgrib2.h"
#include "fnlist.h"

extern int decode, flush_mode;
extern int file_append;
extern int WxText, WxNum;

extern double *lat, *lon;
extern int decode, latlon;

extern bool library_mode;
extern Wind_grid *global_wind_grid;

/*
 * HEADER:100:csv:output:1:make comma separated file, X=file (WxText enabled)
 */


int f_csv(ARG1) {

    char new_inv_out[STRING_SIZE];
    char name[100], desc[100], unit[100];
    FILE *out;

    unsigned int j;
    char vt[20],rt[20];
    int year, month, day, hour, minute, second;
	
    /* initialization phase */

    if (mode == -1) {
        WxText = decode = latlon = 1;
        if ((*local = (void *) ffopen(arg1,file_append ? "a" : "w")) == NULL)
		fatal_error("csv could not open file %s", arg1);  
	return 0;
    }

    /* cleanup phase */

    if (mode == -2) {
	ffclose((FILE *) *local);
	return 0;
    }

    /* processing phase */

    if (lat == NULL || lon == NULL) {
	fprintf(stderr,"csv: latitude/longitude not defined, record skipped\n");
	return 0;
    }

    out = (FILE *) *local;

    /*Collect runtime and validtime into vt and rt*/

    reftime(sec, &year, &month, &day, &hour, &minute, &second);
    sprintf(rt, "%4.4d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d", year,month,day,hour,minute,second);

    vt[0] = 0;
    if (verftime(sec, &year, &month, &day, &hour, &minute, &second) == 0) {
        sprintf(vt,"%4.4d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d", year,month,day,hour,minute,second);
    }

    /*Get levels, parameter name, description and unit*/

    *new_inv_out = 0;
    f_lev(call_ARG0(new_inv_out,NULL));

    if (strcmp(new_inv_out, "reserved")==0) return 0;
//    getName(sec, mode, NULL, name, desc, unit);
      getExtName(sec, mode, NULL, name, desc, unit);
//	fprintf(stderr,"Start processing of %s at %s\n", name, new_inv_out);
//	fprintf(stderr,"Gridpoints in data: %d\n", ndata);
//	fprintf(stderr,"Description: %s, Unit %s\n", desc,unit);

     /* Lage if-setning rundt hele som sjekker om alt eller deler skal ut*/

	const int n_z = global_wind_grid->nb_bar_alts;
	const int n_y = global_wind_grid->nb_lats;
	const int n_x = global_wind_grid->nb_longs;
	const int t_idx = hour - global_wind_grid->timestamps[0];
    if (WxNum > 0) {
        for (j = 0; j < ndata; j++) {
            if (!UNDEFINED_VAL(data[j])) {
            	if (!library_mode) {
            		fprintf(out,"\"%s\",\"%s\",\"%s\",\"%s\",%g,%g,\"%s\"\n",rt,vt,name,
					new_inv_out,lon[j] > 180.0 ?  lon[j]-360.0 : lon[j],lat[j],WxLabel(data[j]));
            	} else {
            		const double longit = lon[j] > 180.0 ?  lon[j]-360.0 : lon[j];
            		const int lat_idx = round((lat[j] - global_wind_grid->initial_latitude) / global_wind_grid->latitude_resolution);
            		const int lon_idx = round((longit - global_wind_grid->initial_longitude) / global_wind_grid->longitude_resolution);
            		for (int bar_alt_idx = 0; bar_alt_idx < NB_BAR_ALT; bar_alt_idx++) {
            			if (starts_with_bar_alt(new_inv_out, global_wind_grid->barometric_altitudes[bar_alt_idx])) {
            				const long long one_d_index = t_idx * (n_z * n_y * n_x) + bar_alt_idx * (n_y * n_x) + lat_idx * n_x + lon_idx;
            				if (strcmp(name, "UGRD") == 0) {
            					global_wind_grid->cells[one_d_index].u_wind = data[j];
				            } else { // VGRD
            					global_wind_grid->cells[one_d_index].v_wind = data[j];
				            }
            				break;
            			}
            		}
            	}
			}
		}
    } else {
		for (j = 0; j < ndata; j++) {
		    if (!UNDEFINED_VAL(data[j])) {
	    		if (!library_mode) {
	    			fprintf(out, "\"%s\",\"%s\",\"%s\",\"%s\",%g,%g,%lg\n",rt,vt,name,
						new_inv_out,lon[j] > 180.0 ?  lon[j]-360.0 : lon[j],lat[j],data[j]);
	    		} else {
	    			const double longit = lon[j] > 180.0 ?  lon[j]-360.0 : lon[j];
	    			const int lat_idx = round((lat[j] - global_wind_grid->initial_latitude) / global_wind_grid->latitude_resolution);
	    			const int lon_idx = round((longit - global_wind_grid->initial_longitude) / global_wind_grid->longitude_resolution);
	    			for (int bar_alt_idx = 0; bar_alt_idx < NB_BAR_ALT; bar_alt_idx++) {
	    				if (starts_with_bar_alt(new_inv_out, global_wind_grid->barometric_altitudes[bar_alt_idx])) {
	    					const long long one_d_index = t_idx * (n_z * n_y * n_x) + bar_alt_idx * (n_y * n_x) + lat_idx * n_x + lon_idx;
	    					if (strcmp(name, "UGRD") == 0) {
	    						global_wind_grid->cells[one_d_index].u_wind = data[j];
	    					} else { // VGRD
	    						global_wind_grid->cells[one_d_index].v_wind = data[j];
	    					}
	    					break;
	    				}
	    			}
	    		}
		    }
		}
    }
    if (flush_mode) fflush(out);
    return 0;
}
