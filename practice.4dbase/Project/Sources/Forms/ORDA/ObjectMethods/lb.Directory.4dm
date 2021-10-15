$event:=FORM Event:C1606

Case of 
	: ($event.code=On Double Clicked:K2:5)
		
		If ($event.row#Null:C1517)
			Form:C1466.modifyRecord()
		End if 
		
End case 