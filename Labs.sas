proc format;
value sex_l 1="Male" 2="Female";
value age_l 1="12 to 14" 
			2="15 to 17"
			3="18 and 19" 
			4="20 to 24"
			5="25 to 29" 
			6="30 to 34"
			7="35 to 39" 
			8="40 to 44"
			9="45 to 49" 
			10="50 to 54"
			11="55 to 59" 
			12="60 to 64"
			13="65 to 69" 
			14="70 to 74"
			15="75 to 79" 
			16=">= 80";
value edu_l 1="< high school"
			2="Graduated high school, no post-secondary"
			3="Post-secondary diploma or degree";
value bmi_l  1="Underweight"
			 2="Normal weight"
			 3="Overweight"
			 4="Obese - Class I, II, III";
value diab_l 1="Yes"
			 2="No";
value oralh_l 0="Poor"
			  1="Good";
value teethfreq_l 1="At least 1x day"
				  2="At least 1x week"
				  3="At least 1x month"
				  4="At least 1x year";
value dentalvisit_l 1="> 1x a year"
					2="About 1x a year"
					3="< 1x a year"
					4="Only for emergency care"
					5="Never";
value food_l 1="Avoids foods - fat, salt, cholesterol, calories"
			 2="Does not avoid foods - fat, salt, cholesterol, calories";
value smokestop_l 0="< 1 year"
				  1="1 to 2 years"
				  2="3 to 5 years"
				  3="6 to 10 years"			
				  4=">= 11 years";
value alcohol_l 1="< 1x a month"
				2="1x a month"
				3="2 to 3x a month"
				4="1x a week"
				5="2 to 3x a week"
				6="4 to 6x a week"
				7="1x a day";
value drugs_l 1="Used drugs - 12 months"
			  2="No drugs - 12 months";
value income_l 1="No income, or income loss"
			   2="< $20,000"
			   3="$20,000 to $39,999"
			   4="$40,000 to $59,999"
			   5="$60,000 to $79,999"
			   6=">= $80,000" ; run;
	

