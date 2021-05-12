#!/usr/local/bin/python3
### Done by abotana@crossvale.com && cmarias@crossvale.com
### Version 1

import time, sys
from selenium import webdriver
from selenium.webdriver.support.ui import Select

options = webdriver.ChromeOptions()
options.add_argument('--ignore-certificate-errors')
options.add_argument('headless')
options.add_argument('--no-sandbox')

# from selenium.webdriver.firefox.options import Options
# Define the webdriver to use.
driver = webdriver.Chrome(executable_path="/bin/chromedriver", chrome_options=options)

# Go to the website
driver.get('https://support.callture.net/extensions.aspx')



userid_login_box = driver.find_element_by_name("ctl00$ContentPlaceHolder1$txtUsername")
userid_login_box.send_keys('office@crossvale.com')

passwd_login_box = driver.find_element_by_name("ctl00$ContentPlaceHolder1$txtPassword")
passwd_login_box.send_keys('YXEaRtbksSprRp2')



userid_ok_button = driver.find_element_by_name("ctl00$ContentPlaceHolder1$btnLogin")
driver.execute_script("arguments[0].click();", userid_ok_button)



select_line = Select(driver.find_element_by_name("ctl00$ContentPlaceHolder1$lstLines"))
select_line.select_by_value("8883368505")



seq = driver.find_element_by_id("ctl00_ContentPlaceHolder1_grdExtensions_ctl02_lnkbCallForwarding")
seq.click()

time.sleep(2)

inputnumber = driver.find_element_by_name("ctl00$ContentPlaceHolder1$Gvdata$ctl02$txtcallnumber")
inputnumber.clear()
time.sleep(1)

number_phone = sys.argv[1]
inputnumber.send_keys(number_phone)

time.sleep(1)

save = driver.find_element_by_id("ctl00_ContentPlaceHolder1_lnkOK")
save.click()
save.click()

time.sleep(4)

driver.quit()
