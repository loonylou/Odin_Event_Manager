# Version 1 - Assignment: Clean phone numbers
Similar to the zip codes, the phone numbers suffer from multiple formats and inconsistencies. If we wanted to allow individuals to sign up for mobile alerts with the phone numbers, we would need to make sure all of the numbers are valid and well-formed.
* If the phone number is less than 10 digits, assume that it is a bad number
* If the phone number is 10 digits, assume that it is good
* If the phone number is 11 digits and the first number is 1, trim the 1 and use the remaining 10 digits
* If the phone number is 11 digits and the first number is not 1, then it is a bad number
* If the phone number is more than 11 digits, assume that it is a bad number