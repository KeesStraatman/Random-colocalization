// This macro assumes you have a binary image open. 
// It will create random points in the binary image and increases the size of this point with a radius the user has selected
// to reflect the dot size you have in your real samples. It will record how many points overlap (colocalize) overlap 
// with the objects of interest (value is 255).
// The user can set the number of repeats, the number of points randomly placed in the image, the radius of the dot and the minimal
// required percentage of the dot that overlaps with the thresholded area in the image.

// The name of the results table includes the name of the image, a unique number, the number of points used in the analysis
// and the overlap percentage. 

// As starting point I used the code published by Olivier Burri on the ImageJ mailing list on 2 June 2014:
// 'Generating random points and tallying proportion of points that fall within object' 

// Kees Straatman, University of Leicester, 20 September 2021


macro random_coloc{
	
	// Set settings
	run("Set Measurements...", "mean redirect=None decimal=3");
	run("Point Tool...", "type=Hybrid color=Red size=Small label");
	
	// Number of points to generate and numer of repeats
	repeats = 10;
	n_points = 100;
	enlarge = 5;
	coloc = 1;
	run("ROI Manager...");

	title = getTitle();

	
	Dialog.create("Settings");
		Dialog.addNumber("Number of simulations", repeats);
		Dialog.addNumber("Number of points per simulation", n_points);
		Dialog.addNumber("Give the radius in pixle size of the area. Use 1 for single pixel", enlarge);
		Dialog.addNumber("Minamal percentage of ROI that should overlap to be counted as colocalized. Select 1 for any overlap", coloc); 
		Dialog.show();
	repeats = Dialog.getNumber();
	n_points = Dialog.getNumber();
	enlarge = Dialog.getNumber();
	coloc = Dialog.getNumber();// count that colocalize
	
	//setBatchMode(true);

	getDimensions(x,y,z,c,t); // Size of the image 

	for(stack = 1; stack<=c; stack++){

		Stack.setSlice(stack);

		for (rep=1; rep <=repeats; rep++){
			// Initialize arrays that will contain point coordinates 
			xcoords = newArray(n_points); 
			ycoords = newArray(n_points); 
	
			// Seed the random number generator 
			random('seed', getTime()); 

			// Create n_points points in XY 
			for (i=0; i<n_points; i++) { 
				xcoords[i] = round(random()*x); 
       			ycoords[i] = round(random()*y); 
				// Check that the point is not on the boarder of the image; mean will be NaN and distance 1
       			if ((xcoords[i]==x)||(ycoords[i]==y)){
       				i = i-1;
       			}
			} 

			// Overlay them on the image 
			makeSelection("point", xcoords, ycoords); 


			// //count points that colocalize
			count = 0;	// counts number of dots inside objects of interest
			
	 
			for (i=0; i<n_points;i++) { 
				// select point
       			makePoint(xcoords[i], ycoords[i]);
       			run("Enlarge...", "enlarge="+enlarge+" pixel");  
       			
       			getStatistics(area, mean, min, max, std, histogram); 
       			perc = 255/100*coloc;  // calculate what the minimal mean intensity value has to be to cover the percentage requested.
			
				// Count points that have a value of 255 (are inside objects of interest)       
				if (coloc == 1){
					if (max == 255) count++;
				}else if (mean >= perc){
					count++;
					roiManager("add");
				}

			} 
		
			// calculate percentage
			
			perc = count/n_points*100;
	
			// Print results
			// Create header with unique name
			if ((rep==1)&&(stack==1)){
								
				if (c == 1){ // Single image
					TN = "["+title+"-"+(round(getTime()/1000))+"_"+n_points+" points_minimal "+coloc+"% colocalization]";
					run("New... ", "name="+TN+"  type=Table");
					print(TN, "\\Headings: \tNumber of points overlap\t% of points overlap");
				}else{
					TN = "["+title+"-"+(round(getTime()/1000))+"_"+n_points+" points_minimal "+coloc+"% colocalization]";
					run("New... ", "name="+TN+"  type=Table");
					print(TN, "\\Headings: \tImage\tNumber of points overlap\t% of points overlap");
				}
			}
				
			// Output to log window.
			if (c == 1){
				print(TN, rep+"\t"+count+"\t"+perc);
			}else{
				print(TN, "image "+stack+"\t"+rep+"\t"+count+"\t"+perc);
			}		
		
		}

	
	} // End of repeat
	
}// End of macro 

