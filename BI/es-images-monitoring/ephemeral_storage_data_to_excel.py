#!/usr/bin/env python

import pandas as pd
from openpyxl import Workbook
from openpyxl.chart import BarChart, Reference
import glob
from pprint import pprint

df_image = pd.read_csv (r'/tmp/container_id_list_for_images_greater_than_GBmaxsize/container_id_list_for_images_greater_than_GBmaxsize.csv')
df_sorted_image = df_image.sort_values(by='Image Size', ascending=False)

df_writable_layer = pd.read_csv (r'/tmp/container_id_list_for_writable_layer_greater_than_MBmaxsize/container_id_list_for_writable_layer_greater_than_MBmaxsize.csv')
df_sorted_writable_layer = df_writable_layer.sort_values(by='Ephemeral Storage Size', ascending=False)

# Number of rows per file
df_image_rows = df_image.shape[0]
df_writable_layer_rows = df_writable_layer.shape[0]


# Create a Pandas Excel writer using XlsxWriter as the engine.
writer = pd.ExcelWriter('/tmp/ephemeral_storage_report.xlsx', engine='xlsxwriter')

# Convert the dataframe to an XlsxWriter Excel object.
df_sorted_image.to_excel(writer, sheet_name='Images')
df_sorted_writable_layer.to_excel(writer, sheet_name='Ephemeral_Storage')


## Cluster wide Images sheet chart and configuration

# Get the xlsxwriter workbook and worksheet objects.
workbook_image_cluster  = writer.book
worksheet_image_cluster = writer.sheets['Images']


if df_image_rows == 0 :

    cell_format = workbook_image_cluster.add_format({'bold': True, 'font_color': 'red'})
    worksheet_image_cluster.write(0, 0, 'No threshold exceeded by any image', cell_format)
    worksheet_image_cluster.set_column('A:A', 60)
    worksheet_image_cluster.set_column('B:N', None, None, {'hidden': True})

else :

    # Create a chart object.
    chart_image_cluster = workbook_image_cluster.add_chart({'type': 'column'})

    # Configure the series of the chart from the dataframe data.
    chart_image_cluster.add_series({
        'categories': '=Images!$H$2:$H$11',
        'values': '=Images!$I$2:$I$11',
        'gap':        10,
    })

    # Set graph title
    chart_image_cluster.set_title({'name': 'Top 10 images size'})

    # Set x axis title
    chart_image_cluster.set_x_axis({
        'name': 'namespace/image',
        'name_font': {'size': 14, 'bold': True},
        'num_font':  {'italic': True },
    })

    # Set y axis title
    chart_image_cluster.set_y_axis({
        'name': 'Size (GBytes)',
        'name_font': {'size': 14, 'bold': True},
        'num_font':  {'italic': True },
    })

    # Disable legend
    chart_image_cluster.set_legend({'position': 'none'})

    # Insert the chart into the worksheet.
    worksheet_image_cluster.insert_chart('O1', chart_image_cluster, {'x_scale': 1, 'y_scale': 1.5})

    # Hide first column
    worksheet_image_cluster.set_column('A:A', None, None, {'hidden': True})

    # Set the columns width
    worksheet_image_cluster.set_column('B:N', 21)



## Cluster wide Ephemeral storage sheet chart and configuration

# Get the xlsxwriter workbook and worksheet objects.
workbook_es_cluster  = writer.book
worksheet_es_cluster = writer.sheets['Ephemeral_Storage']

if df_writable_layer_rows == 0 :

    cell_format = workbook_es_cluster.add_format({'bold': True, 'font_color': 'red'})
    worksheet_es_cluster.write(0, 0, 'No ephemeral storage threshold exceeded by any container', cell_format)
    worksheet_es_cluster.set_column('A:A', 60)
    worksheet_es_cluster.set_column('B:N', None, None, {'hidden': True})

else :

    # Create a chart object.
    chart_es_cluster = workbook_es_cluster.add_chart({'type': 'column'})

    # Configure the series of the chart from the dataframe data.
    chart_es_cluster.add_series({
        'categories': '=Ephemeral_Storage!$E$2:$E$11',
        'values': '=Ephemeral_Storage!$F$2:$F$11',
        'gap':        10,
    })

    # Set graph title
    chart_es_cluster.set_title({'name': 'Top 10 ephemeral storage usage'})

    # Set x axis title
    chart_es_cluster.set_x_axis({
        'name': 'Container',
        'name_font': {'size': 14, 'bold': True},
        'num_font':  {'italic': True },
    })

    # Set y axis title
    chart_es_cluster.set_y_axis({
        'name': 'Ephemeral Storage Size (GBytes)',
        'name_font': {'size': 14, 'bold': True},
        'num_font':  {'italic': True },
    })

    # Disable legend
    chart_es_cluster.set_legend({'position': 'none'})

    # Insert the chart into the worksheet.
    worksheet_es_cluster.insert_chart('O1', chart_es_cluster, {'x_scale': 1, 'y_scale': 1.5})

    # Hide first column
    worksheet_es_cluster.set_column('A:A', None, None, {'hidden': True})

    # Set the columns width
    worksheet_es_cluster.set_column('B:N', 21)


## Node Images sheet chart and configuration

dirlist = glob.glob("/tmp/container_id_list_for_images_greater_than_GBmaxsize/container_id_list_for_images_greater_than_GBmaxsize-*")

# Loop variable for placing the charts on the same sheet
column_count_loop = 1

# Read each node csv file
for node_csv_file in dirlist:
  try:
    # Read the file and add a header for column names
    df_image = pd.read_csv (node_csv_file, sep = ',', names=["Node","Namespace","Pod","Container","Ephemeral Storage Size","Container Image ID","Image Name","Image Size","Author","Container ID","Jenkins Job","Repo Url","Repo Branch"
])
    # Short values by ES size
    df_sorted_image = df_image.sort_values(by='Image Size', ascending=False)

    # Get node name
    node = df_sorted_image.iloc[0,0]

    # Sheet name
    sheet_name_node= 'Image_{}'.format(node)

    # Convert the dataframe to an XlsxWriter Excel object.
    df_sorted_image.to_excel(writer, sheet_name=sheet_name_node)

    # Number of rows per file
    df_image_rows = df_image.shape[0]



## Image sheet chart and configuration

    # Get the xlsxwriter workbook and worksheet objects.
    workbook_image_node  = writer.book
    worksheet_image_node = writer.sheets[sheet_name_node]

    workbook_image_cluster  = writer.book
    worksheet_image_cluster = writer.sheets['Images']


    if df_image_rows == 0 :

        cell_format =  workbook_image_node.add_format({'bold': True, 'font_color': 'red'})
        worksheet_image_node.write(0, 0, 'No threshold exceeded by any image', cell_format)
        worksheet_image_node.set_column('A:A', 60)
        worksheet_image_node.set_column('B:N', None, None, {'hidden': True})

    else :

        chart_image_cluster = workbook_image_cluster.add_chart({'type': 'column'})

        # Configure the series of the chart from the dataframe data.
        chart_image_cluster.add_series({
            'categories': '={}!$H$2:$H$11'.format(sheet_name_node),
            'values': '={}!$I$2:$I$11'.format(sheet_name_node),
            'gap':        10,
        })

       # Set graph title
        chart_image_cluster.set_title({'name': 'Top 10 images size on node {}'.format(node)})

       # Set x axis title
        chart_image_cluster.set_x_axis({
            'name': 'namespace/image',
            'name_font': {'size': 14, 'bold': True},
            'num_font':  {'italic': True },
        })

        # Set y axis title
        chart_image_cluster.set_y_axis({
            'name': 'Size (GBytes)',
            'name_font': {'size': 14, 'bold': True},
            'num_font':  {'italic': True },
        })

        # Disable legend
        chart_image_cluster.set_legend({'position': 'none'})

        # Insert the chart into the cluster image worksheet.
        position= column_count_loop * 24
        worksheet_image_cluster.insert_chart('O{}'.format(position), chart_image_cluster, {'x_scale': 1, 'y_scale': 1.5})
        column_count_loop = column_count_loop + 1

        # Hide first column
        worksheet_image_node.set_column('A:A', None, None, {'hidden': True})

        # Set the columns width
        worksheet_image_node.set_column('B:N', 21)
        worksheet_image_node.hide()

  except:
         pass

## Node Ephemeral storage sheet chart and configuration

dirlist = glob.glob("/tmp/container_id_list_for_writable_layer_greater_than_MBmaxsize/container_id_list_for_writable_layer_greater_than_MBmaxsize-*")

# Loop variable for placing the charts on the same sheet
column_count_loop = 1

# Read each node csv file
for node_csv_file in dirlist:
  try:
    # Read the file and add a header for column names
    df_writable_layer = pd.read_csv (node_csv_file, sep = ',', names=["Node","Namespace","Pod","Container","Ephemeral Storage Size","Container Image ID","Image Name","Image Size","Author","Container ID","Jenkins Job","Repo Url","Repo Branch"
])
    # Short values by ES size
    df_sorted_writable_layer = df_writable_layer.sort_values(by='Ephemeral Storage Size', ascending=False)

    # Get node name
    node = df_sorted_writable_layer.iloc[0,0]

    # Sheet name
    sheet_name_node= 'Ephemeral_Storage_{}'.format(node)

    # Convert the dataframe to an XlsxWriter Excel object.
    df_sorted_writable_layer.to_excel(writer, sheet_name=sheet_name_node)

    # Number of rows per file
    df_writable_layer_rows = df_writable_layer.shape[0]



## Ephemeral storage sheet chart and configuration

    # Get the xlsxwriter workbook and worksheet objects.
    workbook_es_node  = writer.book
    worksheet_es_node = writer.sheets[sheet_name_node]

    workbook_es_cluster  = writer.book
    worksheet_es_cluster = writer.sheets['Ephemeral_Storage']


    if df_writable_layer_rows == 0 :

        cell_format = workbook_es_node.add_format({'bold': True, 'font_color': 'red'})
        worksheet_es_node.write(0, 0, 'No ephemeral storage threshold exceeded by any container', cell_format)
        worksheet_es_node.set_column('A:A', 60)
        worksheet_es_node.set_column('B:N', None, None, {'hidden': True})

    else :


        chart_es_cluster = workbook_es_cluster.add_chart({'type': 'column'})

        # Configure the series of the chart from the dataframe data.
        chart_es_cluster.add_series({
            'categories': '={}!$E$2:$E$11'.format(sheet_name_node),
            'values': '={}!$F$2:$F$11'.format(sheet_name_node),
            'gap':        10,
        })

       # Set graph title
        chart_es_cluster.set_title({'name': 'Top 10 ES usage on node {}'.format(node)})

        # Set x axis title
        chart_es_cluster.set_x_axis({
            'name': 'Container',
            'name_font': {'size': 14, 'bold': True},
            'num_font':  {'italic': True },
        })

        # Set y axis title
        chart_es_cluster.set_y_axis({
            'name': 'Ephemeral Storage (GBytes)',
            'name_font': {'size': 14, 'bold': True},
            'num_font':  {'italic': True },
        })

        # Disable legend
        chart_es_cluster.set_legend({'position': 'none'})


        # Insert the chart into the ES cluster worksheet.
        position= column_count_loop * 24
        worksheet_es_cluster.insert_chart('O{}'.format(position), chart_es_cluster, {'x_scale': 1, 'y_scale': 1.5})
        column_count_loop = column_count_loop + 1

        # Hide first column
        worksheet_es_node.set_column('A:A', None, None, {'hidden': True})

        # Set the columns width
        worksheet_es_node.set_column('B:N', 21)
        worksheet_es_node.hide()

  except:
         pass

# Close the Pandas Excel writer and output the Excel file.
writer.save()

