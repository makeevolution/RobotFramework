*** Settings ***
Library     SeleniumLibrary
Library     Selenium.webdriver.common.by

*** Test Cases ***
TC1:dgdg
    #OPEN BROWSER
    Open Browser    https://playtictactoe.org/  chrome
    ${var}=     Get element attribute    xpath://html/body/div[4]/p[1]/span[4]  innerHTML
    log to console      ${var}


