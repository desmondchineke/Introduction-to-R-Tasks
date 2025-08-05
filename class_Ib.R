

getwd()
dir.create("raw_data")  
dir.create("clean_data") 
dir.create("scripts") 
dir.create("results_or_Tasks") 
dir.create("plots_etc") 



data <- read.csv(file.choose())
View(data)
str(data)


data$gender_fac <- as.factor(data$gender)
str(data)


data$diagnosis_fac <- as.factor(data$diagnosis)
str(data)

data$smoker <- as.factor(data$smoker)
str(data)

data$smoker_num <- ifelse(data$smoker == "Yes", 1, 0)
str(data)




write.csv(data, file = "clean_data/patient_info_clean.csv")

save.image(file = "DesmondChineke_Class_Ib_Assignment.RData")












