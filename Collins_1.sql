#######################################################################
###########   First Step of RTI's Data Scientist Exercise   ###########
#######################################################################
##############      Create data from SQLite Database     ##############
#######################################################################

# SQL query to de-normalize tables and create single table for export
# Exported to CSV using SQLite Manager


SELECT records.id, records.age, workclasses.name AS workclass, education_levels.name AS education_level,
             records.education_num, marital_statuses.name AS marital_status, occupations.name AS occupation,
             relationships.name AS relationship, races.name AS race, sexes.name AS sex, records.capital_gain, records.capital_loss,
             hours_week, countries.name AS country, records.over_50k
FROM records
JOIN workclasses ON records.workclass_id=workclasses.id
JOIN education_levels ON records.education_level_id=education_levels.id
JOIN marital_statuses ON records.marital_status_id=marital_statuses.id
JOIN occupations ON records.occupation_id=occupations.id
JOIN relationships ON records.relationship_id=relationships.id
JOIN races ON records.race_id=races.id
JOIN sexes ON records.sex_id=sexes.id
JOIN countries ON records.country_id=countries.id