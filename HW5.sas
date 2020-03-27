LIBNAME b545 "C:\mySAS\B545";
DATA pimaglu;
    INFILE "C:\mySAS\B545\Pima_fasting_glucose.txt" DLM="09"X FIRSTOBS=2;
    INPUT glucose pregnancies dia_bp skin_fold bmi age;
RUN;
PROC PRINT DATA=pimaglu;
RUN;

/*
I'll start with basic plots & descriptives to explore the 
data, looking at both the uni- & bi-variate distributions
*/
PROC SGPLOT DATA=pimaglu;
    HISTOGRAM glucose;
	DENSITY glucose/ TYPE = NORMAL;
PROC SGPLOT DATA=pimaglu;
    HISTOGRAM pregnancies;
	DENSITY pregnancies/ TYPE = NORMAL;
PROC SGPLOT DATA=pimaglu;
    HISTOGRAM dia_bp;
	DENSITY dia_bp/ TYPE = NORMAL;
PROC SGPLOT DATA=pimaglu;
    HISTOGRAM skin_fold;
	DENSITY skin_fold/ TYPE = NORMAL;
PROC SGPLOT DATA=pimaglu;
    HISTOGRAM bmi;
	DENSITY bmi/ TYPE = NORMAL;
PROC SGPLOT DATA=pimaglu;
    HISTOGRAM age;
	DENSITY age/ TYPE = NORMAL;
RUN;
/* Most variables generally can be seen as normal distributions and the sample size is
   532, which is large enough for normality assumption.*/

PROC SGPLOT DATA=pimaglu;
    SCATTER x= pregnancies y=glucose;
	REG x= pregnancies y=glucose/NOMARKERS;
	LOESS x=pregnancies y=glucose/NOMARKERS;
PROC SGPLOT DATA=pimaglu;
    SCATTER x= dia_bp y=glucose;
	REG x= dia_bp y=glucose/NOMARKERS;
	LOESS x=dia_bp y=glucose/NOMARKERS;
PROC SGPLOT DATA=pimaglu;
    SCATTER x= skin_fold y=glucose;
	REG x= skin_fold y=glucose/NOMARKERS;
	LOESS x=skin_fold y=glucose/NOMARKERS;
PROC SGPLOT DATA=pimaglu;
    SCATTER x= bmi y=glucose;
	REG x= bmi y=glucose/NOMARKERS;
	LOESS x=bmi y=glucose/NOMARKERS;
PROC SGPLOT DATA=pimaglu;
    SCATTER x= age y=glucose;
	REG x= age y=glucose/NOMARKERS;
	LOESS x=age y=glucose/NOMARKERS;
RUN;
PROC MEANS DATA=pimaglu N MIN MEDIAN MAX MEAN STD 
								 SKEW KURT MAXDEC=3;
	VAR glucose pregnancies dia_bp skin_fold bmi age;
RUN;

/*
Here I start by fitting simple linear regression models, and examining
the plot of the residuals against the explanatory variable. 
*/
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= pregnancies;
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= dia_bp;
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= skin_fold;
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= bmi;
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= age;

/*Here I fit a multiple regression model on all five variables.*/
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= pregnancies dia_bp skin_fold bmi age/VIF;
RUN;
QUIT;
/* The model is statistically significant overall(p<0.001). Diagnostic and
residual plots also look good. Low VIF shows that collinearity between 
explanatory variables is low. However, there are some variables like pregnancies,
dia_bp and skin_fold are no longer significant while they are significant when
doing regression on single variable.*/

/*The above condition indicates this model may not be good fit. So, I want to 
drop some variables in the model. First I try to include 4 variables.*/
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= pregnancies dia_bp bmi age;
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= pregnancies dia_bp skin_fold bmi;
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= pregnancies dia_bp skin_fold age;
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= pregnancies skin_fold bmi age;
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= dia_bp skin_fold bmi age;
RUN;
QUIT;
/* No good model among these.*/

/* Then I try to include 3 variables in the model. I do not want to try one by
one because there will be ten models which are too many. According to common
sense, age is associated with pregnancies so I want to drop one of them.Dropping
age is more appropriate based on the results of 4-variable models,also because
pregnancies contains more information than age.Then I want to drop one between
bmi and skin_fold because they are often associated.*/
ODS RTF FILE="C:\mySAS\B545\a5.rtf";
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= pregnancies dia_bp bmi;
PROC REG DATA=pimaglu PLOTS=(RESIDUALS(SMOOTH));
    MODEL glucose= pregnancies dia_bp skin_fold;
RUN;
QUIT;
ODS RTF CLOSE;
/* The first model looks better. All the variables are significant.So,
I would include pregnancies, dia_bp and bmi into my final model.*/

