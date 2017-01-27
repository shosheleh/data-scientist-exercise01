#### import csv and re-bin factors ####
import csv

path_to_file = "C:/Users/Shosheleh/data-scientist-exercise01/census.csv"
path_to_new_file = "C:/Users/Shosheleh/data-scientist-exercise01/pythoned_census.csv"


# import
with open(path_to_file) as f:
    reader = csv.reader(f)
    list_of_rows = [row for row in reader]

# workclass conditional
for row in list_of_rows:
    if row[1] in ['Never-worked', 'Without-Pay']:
        row[1] = 'Unemployed'

# education conditional
for row in list_of_rows:
    if row[2] in ['Preschool', '1st-4th', '5th-6th']:
        row[2] = 'Elementary'
    if row[2] in ['7th-8th']:
         row[2] = 'Middle School'
    if row[2] in ['9th', '10th', '11th', '12th']:
        row[2] = 'Some High School'
    if row[2] in ['HS-grad', 'Some-college']:
        row[2] = 'High School Grad'
    if row[2] in ['Assoc-acdm', 'Assoc-voc']:
        row[2] = 'Associates'
    if row[2] in ['Prof-school', 'Doctorate']:
        row[2] = 'Prof/PhD'

# education_num conditional
for row in list_of_rows:
    if row[3] in ['1', '2', '3']:
        row[3] = '1'
    if row[3] in ['4']:
        row[3] = '2'
    if row[3] in ['5', '6', '7', '8']:
        row[3] = '3'
    if row[3] in ['9', '10']:
        row[3] = '4'
    if row[3] in ['11', '12']:
        row[3] = '5'
    if row[3] in ['13']:
        row[3] = '6'
    if row[3] in ['14']:
        row[3] = '7'
    if row[3] in ['15', '16']:
        row[3] = '8'

# country conditional
for row in list_of_rows:
    if row[12] in ['Cambodia', 'Hong', 'Laos', 'Thailand', 'Vietnam']:
        row[12] = 'SE Asia'
    if row[12] in ['Dominican-Republic', 'Trinadad&Tobago']:
        row[12] = 'Carribean'
    if row[12] in ['El-Salvador', 'Guatemala', 'Nicaragua']:
        row[12] = 'Central America'
    if row[12] in ['England', 'Ireland', 'Scotland']:
        row[12] = 'Great Britain'
    if row[12] in ['Hungary', 'Poland', 'Yugoslavia', 'Holand-Netherlands']:
        row[12] = 'Central Europe'
    if row[12] in ['Outlying-US(Guam-USVI-etc)', 'Philippines']:
        row[12] = 'Philippines-Guam-USVI'

# export
with open(path_to_new_file, 'wb') as nf:
    writer = csv.writer(nf)
    writer.writerows(list_of_rows)


