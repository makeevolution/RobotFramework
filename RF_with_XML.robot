*** Settings ***
Library     XML
Library     OS
Library     Collections

*** Test Cases ***
TestCase1
    ${xml_obj}=    parse xml    employees.xml

    #Validations
    #Val1 - Check Single Element Value
    ${emp_firstname}=   get element text    ${xml_obj}    .//employee[1]/FirstName
    should be equal  ${emp_firstname}   John

    #Val2 - Check Number of elements
    ${count}=   get element count ${xml_obj}    .//employee
    
