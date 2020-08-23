* Create permanent folder;
LIBNAME smoking "C:/Users/namakuto/Documents/Data Management/Assignment 4";   
/*///////////////////////////////// .csv IMPORT and SAS file MERGING ////////////////////*/
FILENAME REFFILE "C:/Users/namakuto/Documents/Data Management/Assignment 4/cchs.csv";
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=smoking.data1;
	GETNAMES=YES;RUN;

/*###############################################
Checking if imported properly + for missing 
data. Explored contents-- cleaning needed 
################################################*/
data smoking.data1; set smoking.data1;
drop var VAR14; run;
proc contents data=smoking.data1; run;
proc freq data=smoking.data1; run;

**** Renaming variables;
data smoking.datalab; set smoking.data1;
rename ALC_015=Alcohol CCC_095=Diabetes DEN_030=DentalVisits DEN_010A=Toothbrushing 
DHHGAGE=Age DHH_SEX=Sex DRMDVLAY=Drugs EHG2DVR3=Education
FDCDVAVD=Food HWTDGBCC=BMI INCDGPER=Income OHT_005=OralH SMKDGSTP=StopSmoking;
run;

/* Loop to group “Valid skip”, “don’t know”, “refused”, 
“did not state” etc., responses together 

Group oral health into "good"/"poor" levels */
data smoking.dataoralh; set smoking.datalab; 
array x education bmi diabetes oralh toothbrushing
dentalvisits food stopsmoking drugs;
do i=1 to dim(x);
if x[i]=>6 and x[i]<=9 then x[i]=.; end; drop i;
if alcohol>=96 then alcohol=.;
if income>=96 then income=.; 

if oralh<=3 and oralh>=1 then oralh = 1; 
else if oralh>3 and oralh<6 then oralh = 0;
run;

*** Open .sas program with value labels;
%INCLUDE "C:/Users/namakuto/Documents/Data Management/Assignment 4/Labs.sas"; 
run;

*** Apply value labels;
data smoking.dataoralh; set smoking.dataoralh;
format Alcohol alcohol_l. Diabetes diab_l. 
DentalVisits dentalvisit_l. Toothbrushing teethfreq_l. 
Age Age_l. Sex Sex_l. Drugs Drugs_l. Education edu_l. 
Food Food_l. BMI bmi_l. Income income_l. 
OralH oralh_l. StopSmoking smokestop_l.;run;

/*###############################################
				Descriptive analyses
################################################*/

proc freq data=smoking.dataoralh;tables _ALL_/missing; run;

*** First, dichotomize "smoking status" variable...
*** Then, bivariate analysis by exposure status;
data modsmoke; set smoking.dataoralh;
if stopsmoking=. then stopsmoking2="Non-former";
else stopsmoking2="former";run;
proc freq data=modsmoke; 
tables stopsmoking2*(age income alcohol diabetes
dentalvisits toothbrushing sex drugs education
food bmi oralh)
/nopercent nocol nofreq nocum missing chisq; run;
*** Bivariate analysis by OUTCOME status;
proc freq data=modsmoke; 
tables oralh*(age income alcohol diabetes
dentalvisits toothbrushing sex drugs education
food bmi stopsmoking)
/nopercent nocol nofreq nocum missing chisq; run;

/*###############################################
				Log-Binomial Model
################################################*/

/* *** Need to make dummies... ;
data smoking.dummies; set smoking.dataoralh;
if stopsmoking=0 then smk0=1; else smk0=0;
if stopsmoking=1 then smk1=1;else smk1=0;
if stopsmoking=2 then smk2=1; else smk2=0;
if stopsmoking=3 then smk3=1;else smk3=0;
if stopsmoking=4 then smk4=1;else smk4=0;

array agex(16); do i=1 to 16; 
if age=i then agex(i)=1; else agex(i)=0;
end; drop i;

array bmix(4); do i=1 to 4;
if bmi=i then bmix(i)=1; else bmix(i)=0;
end;drop i;

array edu(3); do i=1 to 3;
if education=i then edu(i)=1; else edu(i)=0;
end;drop i;

array brushing(4); do i=1 to 4;
if toothbrushing=i then brushing(i)=1; else brushing(i)=0;
end;drop i;

array visits(5); do i=1 to 5;
if dentalvisits=i then visits(i)=1; else visits(i)=0;
end;drop i;

array alc(7); do i=1 to 7;
if alcohol=i then alc(i)=1; else alc(i)=0;
end;drop i;

array inc(6); do i=1 to 6;
if income=i then inc(i)=1; else inc(i)=0;
end;drop i;
run;
*/

/*** Initial model between only 2 variables--
stopsmoking not significant... model convergence.
Overall beta of stopsmoking= -0.0561... ;*/
proc genmod data=smoking.dummies descending;
class oralh (param=ref ref="Poor")
stopsmoking (ref="< 1 year");
model oralh=stopsmoking/ dist=bin link=log lrci;
estimate "RR Good vs Poor" stopsmoking 1-1/exp;run;

/*** check again if oralh differs by levels of the exposure--
i.e., perhaps we need dummies? Chisq not significant,
however....;*/
proc freq data=smoking.dummies;
tables oralh*stopsmoking/ chisq; run;
/*** We will just leave the stopsmoking variable as 
is, for now;*/



*** model could not converge with age... ;
proc genmod data=smoking.dummies descending;
class oralh (param=ref ref="Poor")
age (ref="12 to 14");
model oralh=age/ dist=bin link=log lrci;
estimate "RR Good vs Poor" age 1-1/exp;run;
*** Try with Poisson instead;
data smoking.dummies; set smoking.dummies;
by age notsorted; if age then id+1;run;
proc genmod data=smoking.dummies; class id;
model oralh=age/ dist=poisson link=log lrci;
repeated subject=id;
estimate "RR Good vs Poor" age 1-1/exp;run;


*** still not significant. Try checking again for changes in oralh over age: ;
proc freq data=smoking.dummies;
tables oralh*age/ chisq; run;
/*** some dif in oralh by age groups. Let's try collapsing categories. As age naturally has 16 levels
(and a high number of observations per level), we could technically try dividing into 4 levels. But
for simplicity's sake, we will just try dichotomizing this variable and see what happens. ;*/
data smoking.dummies2; set smoking.dummies; 
if age<=8 then age_bin = 0; 
else if age>8 then age_bin = 1;
run;
proc genmod data=smoking.dummies2 descending;
class oralh (param=ref ref="Poor")
age_bin (ref="0");
model oralh=age_bin/ dist=bin link=log lrci;
estimate "RR Good vs Poor" age_bin 1-1/exp;run;
/** Still not significant but now algorithm converged. Hmm let's examine the association between 
the original 16 levels of age with the exposure.; */



*** edu converged and p<.10... keep as potential confounder;
proc genmod data=smoking.dummies descending;
class oralh (param=ref ref="Poor")
education(ref="< high school");
model oralh=education/ dist=bin link=log lrci;
estimate "RR Good vs Poor" education 1-1/exp;run;

*** bmi p<.05... keep;
proc genmod data=smoking.dummies descending;
class oralh (param=ref ref="Poor")
bmi (ref="Underweight");
model oralh=bmi/ dist=bin link=log lrci;
estimate "RR Good vs Poor" bmi 1-1/exp;run;
* Questionable convergence--use Poisson: ;
data smoking.dummies; set smoking.dummies;
by bmi notsorted; if bmi then id+1;run;
proc genmod data=smoking.dummies; class id;
model oralh=bmi/ dist=poisson link=log lrci;
repeated subject=id;
estimate "RR Good vs Poor" bmi 1-1/exp;run;

*** toothbrushing non-significant;
proc genmod data=smoking.dummies descending;
class oralh (param=ref ref="Poor")
toothbrushing (ref="At least 1x day");
model oralh=toothbrushing/ dist=bin link=log lrci;
estimate "RR Good vs Poor" toothbrushing 1-1/exp;run;

*** dental visits non-significant;
proc genmod data=smoking.dummies descending;
class oralh (param=ref ref="Poor")
dentalvisits(ref="> 1x a year");
model oralh=dentalvisits/ dist=bin link=log lrci;
estimate "RR Good vs Poor" dentalvisits 1-1/exp;run;

*** alcohol non-significant;
proc genmod data=smoking.dummies descending;
class oralh (param=ref ref="Poor")
alcohol (ref="< 1x a month");
model oralh=alcohol/ dist=bin link=log lrci;
estimate "RR Good vs Poor" alcohol 1-1/exp;run;

*** income is non-significant;
proc genmod data=smoking.dummies descending;
class oralh (param=ref ref="Poor")
income (ref="No income, or income loss");
model oralh=income/ dist=bin link=log lrci;
estimate "RR Good vs Poor" income 1-1/exp;run;


*** diabetes, sex, food NOT significant (p>.10);
*** drugs significant;
proc genmod data=smoking.dummies descending;
class oralh (param=ref ref="Poor")
drugs (ref="Used drugs - 12 months");
model oralh=drugs/ dist=bin link=log lrci;
estimate "RR Good vs Poor" drugs 1-1/exp;run;

*** Multivariate model with confounders;
proc genmod data=smoking.dummies descending;
class oralh(param=ref ref="Poor")
drugs(ref="Used drugs - 12 months")
BMI(ref="Obese - Class I, II, III")
stopsmoking(ref="< 1 year");
model oralh=stopsmoking education bmi drugs / dist=bin link=log lrci;
estimate "RR Good vs Poor" stopsmoking 1-1/exp;run;

*** No convergence ... 
*** Must try multivariate Poisson reg;
data smoking.dummies; set smoking.dummies;
by drugs notsorted; if drugs then id+1;run;
proc genmod data=smoking.dummies; class id;
model oralh=stopsmoking bmi drugs / dist=poisson link=log lrci;
repeated subject=id;
estimate "RR Good vs Poor" stopsmoking 1-1/exp;run;

*** Proceed now with using the +-20% change in exposure of interest rule to assess for significant confounders.;

