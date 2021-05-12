# Memory and CPU  data collection of usage, request and limits to Google Spreadsheet

This script is intended to simplify the collection of usage metrics, requests and limits stablished at a container level.
We have created a [google spreadsheet template](https://docs.google.com/spreadsheets/d/1fPutguDB0reo_SrADBrtskUMYRGUis9lw3dKKcJvHpc/edit#gid=149956906) to visualize the cluster data and easily be able to decide an optimal range of requests and quotas.

## Script usage

The script requires no input parameters and will output four .csv files, each corresponding to a sheet of the spreadsheet template. Files will be created in the same directory as the script.

- CPU_project_usage.csv
- MEM_project_usage.csv
- CPU_container_info.csv
- MEM_container_info.csv

The script will take some time to finish, depending on the number of running pods, as it will make a query to prometheus per container. Wait for it to finish before taking any data.

## Dumping data to Google Spreadsheet

In order to keep the style rules, we will be using MacOS Numbers app to copy the data.

Select and copy  only those columns with data. Last three columns correspond to transformations of the data for readability:
![Screenshot 2020-02-12 at 10 19 08](https://user-images.githubusercontent.com/9881318/74320778-84104480-4d81-11ea-980c-5894748097c8.png)


Paste it into the corresponding sheet, with the cursor on A1 cell
![Screenshot 2020-02-12 at 10 12 53](https://user-images.githubusercontent.com/9881318/74320080-4f4fbd80-4d80-11ea-9af7-3350e2586c1d.png)

## Now you are ready to start thinking about the quotas and limits!
